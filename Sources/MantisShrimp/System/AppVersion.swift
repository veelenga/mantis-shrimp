import Foundation

enum AppVersion {
    private static let versionKey = "CFBundleShortVersionString"
    private static let unbundledTitle = "Development build"

    static var menuTitle: String {
        guard let version = Bundle.main.object(forInfoDictionaryKey: versionKey) as? String else {
            return unbundledTitle
        }
        return "Version \(version)"
    }
}
