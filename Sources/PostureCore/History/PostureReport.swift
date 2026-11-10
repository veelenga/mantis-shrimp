import Foundation

public struct PostureReport: Equatable {
    public static let empty = PostureReport(interval: DateInterval(), summary: PostureSummary(records: []), buckets: [])

    public let interval: DateInterval
    public let summary: PostureSummary
    public let buckets: [PostureBucket]

    public init(interval: DateInterval, summary: PostureSummary, buckets: [PostureBucket]) {
        self.interval = interval
        self.summary = summary
        self.buckets = buckets
    }

    public init(records: [PostureMinuteRecord], component: Calendar.Component, interval: DateInterval, calendar: Calendar) {
        self.init(
            interval: interval,
            summary: PostureSummary(records: records),
            buckets: PostureStats.buckets(records, by: component, in: interval, calendar: calendar)
        )
    }

    public var hasData: Bool {
        summary.trackedSeconds > 0
    }
}
