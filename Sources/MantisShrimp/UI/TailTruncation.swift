import AppKit

enum TailTruncation {
    private static let ellipsis = "…"
    private static let dangling = CharacterSet.whitespaces.union(CharacterSet(charactersIn: ",·"))

    static func fit(_ text: String, width: CGFloat, font: NSFont) -> String {
        guard measuredWidth(of: text, font: font) > width else { return text }
        let characters = Array(text)
        var fitting = 0
        var overflowing = characters.count
        while overflowing - fitting > 1 {
            let candidate = (fitting + overflowing) / 2
            if measuredWidth(of: truncated(characters, to: candidate), font: font) <= width {
                fitting = candidate
            } else {
                overflowing = candidate
            }
        }
        return truncated(characters, to: fitting)
    }

    static func measuredWidth(of text: String, font: NSFont) -> CGFloat {
        (text as NSString).size(withAttributes: [.font: font]).width
    }

    private static func truncated(_ characters: [Character], to count: Int) -> String {
        String(characters.prefix(count)).trimmingCharacters(in: dangling) + ellipsis
    }
}
