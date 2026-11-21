import Foundation

enum AppVersion {
    private static let versionKey = "CFBundleShortVersionString"
    private static let unbundledLabel = "Development build"

    static var label: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: versionKey) as? String else {
            return unbundledLabel
        }
        return "Version \(version)"
    }
}
