import AppKit

@MainActor
enum MenuWidthLock {
    private static let roundingSlack: CGFloat = 1

    static func lock(_ menu: NSMenu, to preferredWidth: CGFloat, flexibleItem: NSMenuItem) -> CGFloat {
        flexibleItem.title = ""
        menu.minimumWidth = 0
        let naturalWidth = menu.size.width
        let lockedWidth = max(naturalWidth, preferredWidth)
        menu.minimumWidth = lockedWidth
        let widestTitle = menu.items
            .map { TailTruncation.measuredWidth(of: $0.title, font: menu.font) }
            .max() ?? 0
        return widestTitle + lockedWidth - naturalWidth - roundingSlack
    }
}
