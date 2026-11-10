import AppKit
import AVFoundation
import PostureCore

final class CameraPreviewView: NSView {
    private static let readoutHeight = CameraWindowSizing.readoutHeight
    private static let readoutInset: CGFloat = 14
    private static let buttonMargin: CGFloat = 12
    private static let calibrateTitle = "Calibrate"
    private static let calibratingTitle = "Calibrating…"

    var onCalibrate: (() -> Void)?

    private let previewLayer: AVCaptureVideoPreviewLayer
    private let overlay = LandmarkOverlay()
    private let readout = MetricsReadoutView()
    private lazy var calibrateButton = NSButton(title: Self.calibrateTitle, target: self, action: #selector(calibrate))

    init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        super.init(frame: .zero)
        wantsLayer = true
        addLayers()
        configureCalibrateButton()
    }

    private func addLayers() {
        layer?.addSublayer(previewLayer)
        layer?.addSublayer(overlay)
        addSubview(readout)
    }

    private func configureCalibrateButton() {
        calibrateButton.bezelStyle = .rounded
        addSubview(calibrateButton)
    }

    func setCalibrating(_ isCalibrating: Bool) {
        calibrateButton.title = isCalibrating ? Self.calibratingTitle : Self.calibrateTitle
        calibrateButton.isEnabled = !isCalibrating
        needsLayout = true
    }

    @objc private func calibrate() {
        onCalibrate?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var wantsUpdateLayer: Bool { true }

    override func updateLayer() {
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    override func layout() {
        super.layout()
        let readoutFrame = NSRect(x: 0, y: 0, width: bounds.width, height: Self.readoutHeight)
        readout.frame = readoutFrame.insetBy(dx: Self.readoutInset, dy: Self.readoutInset)
        let videoFrame = NSRect(x: 0, y: Self.readoutHeight, width: bounds.width, height: bounds.height - Self.readoutHeight)
        let buttonSize = calibrateButton.fittingSize
        calibrateButton.frame = NSRect(
            x: videoFrame.maxX - Self.buttonMargin - buttonSize.width,
            y: videoFrame.maxY - Self.buttonMargin - buttonSize.height,
            width: buttonSize.width,
            height: buttonSize.height
        )
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        previewLayer.frame = videoFrame
        overlay.frame = videoFrame
        CATransaction.commit()
    }

    func render(_ analysis: FrameAnalysis) {
        overlay.render(analysis, mirrored: previewLayer.connection?.isVideoMirrored ?? false)
        readout.render(rows: MetricsText.rows(for: analysis), issuesLine: MetricsText.issuesLine(for: analysis))
    }
}
