import AppKit

final class ClosableWindow: NSWindow {
    private static let closeKey = "w"

    override func cancelOperation(_ sender: Any?) {
        performClose(sender)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let isCommandW = event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command
            && event.charactersIgnoringModifiers == Self.closeKey
        guard isCommandW else { return super.performKeyEquivalent(with: event) }
        performClose(nil)
        return true
    }
}
