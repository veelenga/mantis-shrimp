import Foundation

enum PercentText {
    private static let plainFormat = "%.0f%%"
    private static let percentScale = 100.0

    static func format(_ fraction: Double) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)))
    }

    static func plain(_ fraction: Double) -> String {
        String(format: plainFormat, fraction * percentScale)
    }
}
