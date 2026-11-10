import AppKit
import ShrimpArt

@MainActor
final class AlertBannerPanel {
    private static let horizontalPadding: CGFloat = 20
    private static let verticalPadding: CGFloat = 14
    private static let iconSize: CGFloat = 36
    private static let iconSpacing: CGFloat = 14
    private static let cornerRadius: CGFloat = 14
    private static let topMargin: CGFloat = 12
    private static let maxTextWidth: CGFloat = 460
    private static let textSpacing: CGFloat = 3
    private static let titleFontSizeDelta: CGFloat = 3
    private static let hintAlpha: CGFloat = 0.85
    private static let maxMessageLines = 2

    var onClick: (() -> Void)?

    private let panel: NSPanel
    private let message = NSTextField(wrappingLabelWithString: "")
    private let hint = NSTextField(labelWithString: "")
    private let icon = NSImageView()
    private var shownText: AlertText?

    init() {
        panel = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        configurePanel()
        configureSubviews()
    }

    func show(_ text: AlertText) {
        guard shownText != text || !panel.isVisible else { return }
        shownText = text
        message.stringValue = text.message
        hint.stringValue = text.hint
        icon.image = NSImage.shrimpGlyph(pose: text.pose, size: NSSize(width: Self.iconSize, height: Self.iconSize), color: .white)
        resizeToFit()
        panel.orderFrontRegardless()
    }

    func hide() {
        panel.orderOut(nil)
    }

    private func configurePanel() {
        panel.level = .statusBar
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isReleasedWhenClosed = false
    }

    private func configureSubviews() {
        configureIcon()
        configureMessage()
        let content = NSView()
        content.wantsLayer = true
        content.layer?.backgroundColor = PostureTint.issue.color.cgColor
        content.layer?.cornerRadius = Self.cornerRadius
        content.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(clicked)))

        let row = NSStackView(views: [icon, textColumn()])
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = Self.iconSpacing
        row.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: Self.horizontalPadding),
            row.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -Self.horizontalPadding),
            row.topAnchor.constraint(equalTo: content.topAnchor, constant: Self.verticalPadding),
            row.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -Self.verticalPadding),
        ])
        panel.contentView = content
    }

    private func configureIcon() {
        icon.setContentHuggingPriority(.required, for: .horizontal)
        icon.widthAnchor.constraint(equalToConstant: Self.iconSize).isActive = true
        icon.heightAnchor.constraint(equalToConstant: Self.iconSize).isActive = true
    }

    private func configureMessage() {
        message.font = .systemFont(ofSize: NSFont.systemFontSize + Self.titleFontSizeDelta, weight: .semibold)
        message.textColor = .white
        message.maximumNumberOfLines = Self.maxMessageLines
        message.preferredMaxLayoutWidth = Self.maxTextWidth
        hint.font = .systemFont(ofSize: NSFont.systemFontSize)
        hint.textColor = NSColor.white.withAlphaComponent(Self.hintAlpha)
    }

    private func textColumn() -> NSStackView {
        let column = NSStackView(views: [message, hint])
        column.orientation = .vertical
        column.alignment = .leading
        column.spacing = Self.textSpacing
        return column
    }

    private func resizeToFit() {
        guard let content = panel.contentView, let screen = NSScreen.main else { return }
        content.layoutSubtreeIfNeeded()
        let size = content.fittingSize
        let origin = NSPoint(
            x: screen.visibleFrame.midX - size.width / 2,
            y: screen.visibleFrame.maxY - size.height - Self.topMargin
        )
        panel.setFrame(NSRect(origin: origin, size: size), display: true)
    }

    @objc private func clicked() {
        onClick?()
    }
}
