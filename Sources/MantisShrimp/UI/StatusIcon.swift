import AppKit
import PostureCore
import ShrimpArt

enum StatusIcon {
    enum Key: Equatable {
        case paused
        case cameraUnavailable
        case personNotVisible
        case calibrating
        case good
        case issue
    }

    private static let glyphSize = NSSize(width: 18, height: 18)
    private static let glyphInset: CGFloat = 0.5
    private static let pausedAlpha: CGFloat = 0.45
    private static let symbolPointSize: CGFloat = 16

    static func key(for snapshot: MonitorSnapshot) -> Key {
        switch snapshot.phase {
        case .paused: .paused
        case .cameraUnavailable: .cameraUnavailable
        case .personNotVisible: .personNotVisible
        case .calibrating: .calibrating
        case .posture: snapshot.hasInstantIssues ? .issue : .good
        }
    }

    static func image(for key: Key) -> NSImage {
        switch key {
        case .paused: shrimp(.tall, color: .labelColor.withAlphaComponent(pausedAlpha), template: true)
        case .cameraUnavailable: symbol("video.slash")
        case .personNotVisible: shrimp(.tall, color: .labelColor, template: true)
        case .calibrating: symbol("scope")
        case .good: shrimp(.tall, color: PostureTint.good.color, template: false)
        case .issue: shrimp(.curled, color: PostureTint.issue.color, template: false)
        }
    }

    private static func shrimp(_ pose: ShrimpShape.Pose, color: NSColor, template: Bool) -> NSImage {
        let image = NSImage.shrimpGlyph(pose: pose, size: glyphSize, color: color, inset: glyphInset)
        image.isTemplate = template
        return image
    }

    private static func symbol(_ name: String) -> NSImage {
        let configuration = NSImage.SymbolConfiguration(pointSize: symbolPointSize, weight: .regular)
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil) ?? NSImage()
        let sized = image.withSymbolConfiguration(configuration) ?? image
        sized.isTemplate = true
        return sized
    }
}
