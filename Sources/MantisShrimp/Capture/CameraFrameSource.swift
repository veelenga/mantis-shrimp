@preconcurrency import AVFoundation
import PostureCore
import os

final class CameraFrameSource: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    enum CameraError: Error {
        case accessDenied
        case noCamera
        case configurationFailed
    }

    private static let log = Logger(subsystem: "dev.veelenga.mantisshrimp", category: "camera")

    var onFrame: ((CVPixelBuffer) -> Void)?

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "mantisshrimp.camera")
    private var device: AVCaptureDevice?
    private var framing: CameraFraming
    private var mode = CameraMode.active
    private lazy var previewLayer = makePreviewLayer()
    private var lastBufferSize = CGSize.zero
    private var desiredSize = CGSize.zero
    private var reapplyPolicy = FormatReapplyPolicy()

    init(framing: CameraFraming) {
        self.framing = framing
    }

    func start() async throws {
        Self.disableCenterStage()
        guard await Self.requestAccess() else { throw CameraError.accessDenied }
        try configureSessionIfNeeded()
        queue.async { [weak self] in
            guard let self else { return }
            self.session.startRunning()
            self.reapplyPolicy.reset()
            self.applyFormat()
        }
    }

    func stop() {
        queue.async { [session] in session.stopRunning() }
    }

    func setMode(_ mode: CameraMode) {
        queue.async { [weak self] in
            self?.mode = mode
            self?.applyFormat()
        }
    }

    func setFraming(_ framing: CameraFraming) {
        queue.async { [weak self] in
            self?.framing = framing
            self?.reapplyPolicy.reset()
            self?.applyFormat()
        }
    }

    func preview() -> AVCaptureVideoPreviewLayer {
        previewLayer
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        logBufferSizeIfChanged(pixelBuffer)
        onFrame?(pixelBuffer)
    }

    private func logBufferSizeIfChanged(_ buffer: CVPixelBuffer) {
        let size = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        if size != lastBufferSize {
            lastBufferSize = size
            Self.log.notice("frames now \(Int(size.width))x\(Int(size.height))")
        }
        reapplyFormatIfFramesMismatch(size)
    }

    private func reapplyFormatIfFramesMismatch(_ size: CGSize) {
        let now = ProcessInfo.processInfo.systemUptime
        guard reapplyPolicy.shouldReapply(actual: size, desired: desiredSize, now: now) else { return }
        applyFormat()
    }

    private static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }

    private func configureSessionIfNeeded() throws {
        guard device == nil else { return }
        guard let camera = AVCaptureDevice.default(for: .video) else { throw CameraError.noCamera }

        session.beginConfiguration()
        defer { session.commitConfiguration() }

        let input = try AVCaptureDeviceInput(device: camera)
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)

        guard session.canAddInput(input), session.canAddOutput(output) else {
            throw CameraError.configurationFailed
        }
        session.addInput(input)
        session.addOutput(output)
        _ = previewLayer
        device = camera
    }

    private func makePreviewLayer() -> AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspect
        layer.connection?.automaticallyAdjustsVideoMirroring = false
        layer.connection?.isVideoMirrored = true
        return layer
    }

    private func applyFormat() {
        guard let device else { return }
        reapplyPolicy.recordApply(at: ProcessInfo.processInfo.systemUptime)
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            if let format = CameraFormatSelector.bestFormat(for: framing, among: device.formats) {
                let wanted = format.formatDescription.dimensions
                desiredSize = CGSize(width: Int(wanted.width), height: Int(wanted.height))
                if device.activeFormat != format {
                    device.activeFormat = format
                }
            }
            device.activeVideoMinFrameDuration = Self.frameDuration(for: mode.profile.frameRate, on: device)
        } catch {
            Self.log.error("camera configuration failed: \(error.localizedDescription)")
        }
        let size = device.activeFormat.formatDescription.dimensions
        Self.log.notice("camera format \(size.width)x\(size.height), framing \(self.framing.rawValue, privacy: .public), center stage \(AVCaptureDevice.isCenterStageEnabled), mode \(String(describing: self.mode), privacy: .public)")
    }

    private static func frameDuration(for frameRate: Int32, on device: AVCaptureDevice) -> CMTime {
        let desired = CMTime(value: 1, timescale: frameRate)
        let slowestSupported = device.activeFormat.videoSupportedFrameRateRanges.map(\.maxFrameDuration).max() ?? desired
        return min(desired, slowestSupported)
    }

    private static func disableCenterStage() {
        AVCaptureDevice.centerStageControlMode = .app
        AVCaptureDevice.isCenterStageEnabled = false
    }
}
