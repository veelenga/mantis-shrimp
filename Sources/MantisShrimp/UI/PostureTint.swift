import AppKit

enum PostureTint {
    case good
    case issue

    var color: NSColor {
        switch self {
        case .good: .systemGreen
        case .issue: .systemOrange
        }
    }
}
