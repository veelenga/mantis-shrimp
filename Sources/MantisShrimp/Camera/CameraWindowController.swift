import AppKit
import PostureCore

@MainActor
final class CameraWindowController: NSObject, NSWindowDelegate {
    private static let title = "Camera"
    private static let styleMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]

    private let monitor: PostureMonitor
    private var window: NSWindow?
    private var previewView: CameraPreviewView?
    private var frameSize = CGSize.zero

    init(monitor: PostureMonitor) {
        self.monitor = monitor
        super.init()
        monitor.observe { [weak self] snapshot in
            self?.previewView?.setCalibrating(snapshot.phase == .calibrating)
        }
    }

    func show() {
        let window = window ?? makeWindow()
        self.window = window
        monitor.setPreviewing(true)
        monitor.onFrameAnalysis = { [weak self] analysis in
            self?.fitWindow(to: analysis.frameSize)
            self?.previewView?.render(analysis)
        }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        monitor.onFrameAnalysis = nil
        monitor.setPreviewing(false)
    }

    private func fitWindow(to size: CGSize) {
        guard size != frameSize, size.width > 0, size.height > 0, let window else { return }
        frameSize = size
        let contentSize = CameraWindowSizing.contentSize(for: size)
        window.contentAspectRatio = contentSize
        window.setContentSize(contentSize)
        window.center()
    }

    private func makeWindow() -> NSWindow {
        let preview = CameraPreviewView(previewLayer: monitor.makePreviewLayer())
        preview.onCalibrate = { [weak self] in self?.monitor.calibrate() }
        previewView = preview
        let window = ClosableWindow(
            contentRect: NSRect(origin: .zero, size: CameraWindowSizing.initialContentSize),
            styleMask: Self.styleMask,
            backing: .buffered,
            defer: false
        )
        window.title = Self.title
        window.isReleasedWhenClosed = false
        window.contentView = preview
        window.contentAspectRatio = CameraWindowSizing.initialContentSize
        window.delegate = self
        window.center()
        return window
    }
}
