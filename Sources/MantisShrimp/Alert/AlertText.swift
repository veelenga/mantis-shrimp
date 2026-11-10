import Foundation
import PostureCore
import ShrimpArt

struct AlertText: Equatable {
    let message: String
    let hint: String
    let pose: ShrimpShape.Pose

    static func text(for alert: MonitorAlert) -> AlertText {
        switch alert {
        case .posture(let issues):
            AlertText(message: "Fix your posture: " + issues.joinedTitles.lowercasedFirst(), hint: hint(snooze: MonitorTiming.Alert.snooze), pose: .curled)
        case .sittingTooLong(let minutes):
            AlertText(message: "Time to stand up, you have been sitting for \(minutes) minutes", hint: hint(snooze: MonitorTiming.Sitting.snooze), pose: .tall)
        }
    }

    private static func hint(snooze: TimeInterval) -> String {
        "Click to snooze for \(Int(snooze / TimeInterval.secondsPerMinute)) minutes"
    }
}

private extension String {
    func lowercasedFirst() -> String {
        prefix(1).lowercased() + dropFirst()
    }
}
