import AVFoundation
import CoreVideo
import Foundation
import PostureCore

@MainActor
final class PostureMonitor {
    var onFrameAnalysis: ((FrameAnalysis) -> Void)?

    private(set) var snapshot: MonitorSnapshot {
        didSet { if snapshot != oldValue { observers.forEach { $0(snapshot) } } }
    }

    private(set) var settings: MonitorSettings {
        didSet {
            settingsStore.save(settings)
            evaluator = PostureEvaluator(settings: settings)
        }
    }

    private(set) var isRunning = false

    private var observers: [(MonitorSnapshot) -> Void] = []
    private let settingsStore: SettingsStore
    private let recorder: PostureRecorder
    private let camera: CameraFrameSource
    private nonisolated let analyzer = FrameAnalyzer(interval: CameraMode.active.profile.analysisInterval)
    private var evaluator: PostureEvaluator
    private var sustained = SustainedIssueDetector(onsetDelay: MonitorTiming.Detection.onsetDelay, releaseDelay: MonitorTiming.Detection.releaseDelay)
    private var calibrator = MetricsCalibrator(duration: MonitorTiming.Camera.calibrationDuration)
    private var alerts: AlertCenter
    private var presence = PresenceTracker()
    private var detectionHold = LastValueHold<FrameDetection>(duration: MonitorTiming.Detection.hold)
    private var isPreviewing = false
    private var isLowPower = false
    private var suspendedWhileRunning = false
    private var cameraMode = CameraMode.active {
        didSet {
            guard cameraMode != oldValue else { return }
            camera.setMode(cameraMode)
            analyzer.interval = cameraMode.profile.analysisInterval
        }
    }

    init(settingsStore: SettingsStore, recorder: PostureRecorder) {
        self.settingsStore = settingsStore
        self.recorder = recorder
        let settings = settingsStore.load()
        self.settings = settings
        self.camera = CameraFrameSource(framing: settings.cameraFraming)
        self.evaluator = PostureEvaluator(settings: settings)
        self.alerts = AlertCenter(alertDelay: settings.alertDelay)
        self.snapshot = MonitorSnapshot(phase: .paused, isCalibrated: settings.isCalibrated)
        camera.onFrame = { [weak self] buffer in self?.process(buffer) }
    }

    func observe(_ observer: @escaping (MonitorSnapshot) -> Void) {
        observers.append(observer)
        observer(snapshot)
    }

    func start() {
        Task {
            do {
                try await camera.start()
                isRunning = true
                suspendedWhileRunning = false
                publish(phase: .personNotVisible)
            } catch {
                publish(phase: .cameraUnavailable)
            }
        }
    }

    func pause() {
        camera.stop()
        isRunning = false
        calibrator.cancel()
        resetTrackers()
        recorder.flush()
        publish(phase: .paused)
    }

    func suspend() {
        guard isRunning else { return }
        pause()
        suspendedWhileRunning = true
    }

    func resume() {
        guard suspendedWhileRunning else { return }
        start()
    }

    func shutDown() {
        recorder.flush()
    }

    func calibrate() {
        if !isRunning { start() }
        calibrator.start(at: now)
    }

    func setSensitivity(_ sensitivity: Sensitivity) {
        settings.sensitivity = sensitivity
        sustained.reset()
    }

    func setAlertDelay(_ delay: AlertDelay) {
        guard delay != settings.alertDelay else { return }
        settings.alertDelay = delay
        alerts.rebuildPosture(for: delay)
        if case .posture = snapshot.alert { snapshot.alert = nil }
    }

    func setCameraFraming(_ framing: CameraFraming) {
        guard framing != settings.cameraFraming else { return }
        settings.cameraFraming = framing
        sustained.reset()
        camera.setFraming(framing)
        publish(phase: snapshot.phase)
    }

    func setPreviewing(_ previewing: Bool) {
        isPreviewing = previewing
        updateCameraMode(at: now)
    }

    func setLowPowerMode(_ enabled: Bool) {
        isLowPower = enabled
        updateCameraMode(at: now)
    }

    func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        camera.preview()
    }

    func snoozeAlert() {
        guard let alert = snapshot.alert else { return }
        alerts.snooze(alert, at: now)
        snapshot.alert = nil
    }

    private var now: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }

    nonisolated private func process(_ buffer: CVPixelBuffer) {
        guard let frame = analyzer.analyze(buffer) else { return }
        Task { @MainActor in self.handle(frame.detection, frameSize: frame.frameSize) }
    }

    private func handle(_ fresh: FrameDetection?, frameSize: CGSize) {
        guard isRunning else { return }
        let time = now
        let detection = detectionHold.update(fresh, at: time)
        trackPresence(detection != nil, at: time)
        guard let detection else {
            resetPostureTrackingIfAwayLong(at: time)
            recordUnmeasured(phase: .personNotVisible)
            onFrameAnalysis?(.empty(frameSize: frameSize, thresholds: evaluator.thresholds))
            return
        }
        let metrics = detection.metrics
        let instantIssues = evaluator.evaluate(metrics)
        onFrameAnalysis?(FrameAnalysis(
            frameSize: frameSize,
            landmarks: detection.landmarks,
            deviations: evaluator.deviations(of: metrics),
            thresholds: evaluator.thresholds,
            instantIssues: instantIssues
        ))
        if calibrator.isRunning, !finishCalibration(with: metrics, at: time) {
            recordUnmeasured(phase: .calibrating)
            return
        }
        let issues = sustained.update(instantIssues, at: time)
        recorder.record(.measured(issues))
        alerts.updatePosture(hasIssues: !issues.isEmpty, at: time)
        publish(phase: .posture(sustained: issues, instant: instantIssues))
    }

    private func recordUnmeasured(phase: MonitorPhase) {
        recorder.record(.unmeasured)
        publish(phase: phase)
    }

    private func resetPostureTrackingIfAwayLong(at time: TimeInterval) {
        guard let absence = presence.state.absence(at: time), absence >= MonitorTiming.Camera.resetAfterAbsence else { return }
        sustained.reset()
        alerts.resetPosture()
    }

    private func trackPresence(_ isPresent: Bool, at time: TimeInterval) {
        presence.update(isPresent: isPresent, at: time)
        alerts.updateSitting(duration: presence.state.sittingDuration, at: time)
        snapshot.sittingMinutes = presence.state.sittingMinutes
        updateCameraMode(at: time)
    }

    private func updateCameraMode(at time: TimeInterval) {
        cameraMode = CameraMode.resolve(
            isPreviewing: isPreviewing,
            isLowPower: isLowPower,
            absentFor: presence.state.absence(at: time)
        )
    }

    private func finishCalibration(with metrics: PostureMetrics, at time: TimeInterval) -> Bool {
        guard let baseline = calibrator.add(metrics, at: time) else { return false }
        settings.baseline = baseline
        sustained.reset()
        return true
    }

    private func resetTrackers() {
        sustained.reset()
        alerts.reset()
        presence.reset()
        detectionHold.reset()
    }

    private func publish(phase: MonitorPhase) {
        snapshot = MonitorSnapshot(
            phase: phase,
            isCalibrated: settings.isCalibrated,
            alert: currentAlert(for: phase),
            sittingMinutes: snapshot.sittingMinutes
        )
    }

    private func currentAlert(for phase: MonitorPhase) -> MonitorAlert? {
        var issues: Set<PostureIssue> = []
        if case .posture(let sustained, _) = phase { issues = sustained }
        return alerts.currentAlert(for: issues, sittingMinutes: snapshot.sittingMinutes)
    }
}
