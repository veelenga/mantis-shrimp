import AppKit

final class VideoOverlayButton: NSVisualEffectView {
    private static let padding = NSSize(width: 12, height: 6)
    private static let cornerRadius: CGFloat = 8

    var onPress: (() -> Void)?

    var title: String {
        get { button.title }
        set { button.title = newValue }
    }

    var isEnabled: Bool {
        get { button.isEnabled }
        set { button.isEnabled = newValue }
    }

    private lazy var button = NSButton(title: "", target: self, action: #selector(press))

    init(title: String) {
        super.init(frame: .zero)
        configureBackdrop()
        button.title = title
        button.isBordered = false
        addSubview(button)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var fittingSize: NSSize {
        let titleSize = button.fittingSize
        return NSSize(
            width: titleSize.width + Self.padding.width * 2,
            height: titleSize.height + Self.padding.height * 2
        )
    }

    override func layout() {
        super.layout()
        button.frame = bounds
    }

    private func configureBackdrop() {
        material = .hudWindow
        blendingMode = .withinWindow
        state = .active
        appearance = NSAppearance(named: .darkAqua)
        wantsLayer = true
        layer?.cornerRadius = Self.cornerRadius
        layer?.masksToBounds = true
    }

    @objc private func press() {
        onPress?()
    }
}
