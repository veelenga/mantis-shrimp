import Foundation

enum StatsRange: CaseIterable, Identifiable {
    private static let daysInWeek = 7
    private static let daysInThirtyDayRange = 30

    case today
    case lastSevenDays
    case lastThirtyDays

    var id: Self { self }

    var title: String {
        switch self {
        case .today: "Today"
        case .lastSevenDays: "7 days"
        case .lastThirtyDays: "30 days"
        }
    }

    var bucketComponent: Calendar.Component {
        switch self {
        case .today: .hour
        case .lastSevenDays, .lastThirtyDays: .day
        }
    }

    var bucketUnitName: String {
        switch bucketComponent {
        case .hour: "hour"
        default: "day"
        }
    }

    var chartTitle: String {
        "Good posture by \(bucketUnitName)"
    }

    var reportBucketTitle: String {
        "By \(bucketUnitName)"
    }

    func interval(endingAt now: Date, calendar: Calendar) -> DateInterval {
        let startOfToday = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
        let start = calendar.date(byAdding: .day, value: 1 - dayCount, to: startOfToday) ?? startOfToday
        return DateInterval(start: start, end: end)
    }

    private var dayCount: Int {
        switch self {
        case .today: 1
        case .lastSevenDays: Self.daysInWeek
        case .lastThirtyDays: Self.daysInThirtyDayRange
        }
    }
}
