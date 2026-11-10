import AppKit

@MainActor
final class OptionSubmenu<Option: RawRepresentable & CaseIterable & Hashable>: NSObject {
    let menuItem: NSMenuItem
    private var items: [Option: NSMenuItem] = [:]
    private let onSelect: (Option) -> Void

    init(
        title: String,
        optionTitle: (Option) -> String,
        separatorAfter: Option? = nil,
        onSelect: @escaping (Option) -> Void
    ) {
        self.onSelect = onSelect
        menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        super.init()
        let submenu = NSMenu()
        for option in Option.allCases {
            let entry = NSMenuItem(title: optionTitle(option), action: #selector(selected(_:)), keyEquivalent: "")
            entry.target = self
            entry.representedObject = option
            items[option] = entry
            submenu.addItem(entry)
            if option == separatorAfter { submenu.addItem(.separator()) }
        }
        menuItem.submenu = submenu
    }

    func update(selected: Option) {
        for (option, entry) in items {
            entry.state = option == selected ? .on : .off
        }
    }

    @objc private func selected(_ sender: NSMenuItem) {
        guard let option = sender.representedObject as? Option else { return }
        onSelect(option)
    }
}
