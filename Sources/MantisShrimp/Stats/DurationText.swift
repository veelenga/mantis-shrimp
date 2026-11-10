import Foundation
import PostureCore

enum DurationText {
    private static let minutesPerHour = 60

    static func format(_ seconds: Double) -> String {
        let totalMinutes = Int((seconds / TimeInterval.secondsPerMinute).rounded())
        let hours = totalMinutes / minutesPerHour
        let minutes = totalMinutes % minutesPerHour
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}
