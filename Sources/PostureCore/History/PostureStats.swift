import Foundation

public enum PostureStats {
    public static func buckets(
        _ records: [PostureMinuteRecord],
        by component: Calendar.Component,
        in interval: DateInterval,
        calendar: Calendar
    ) -> [PostureBucket] {
        let recordsByStart = Dictionary(grouping: records) { record in
            calendar.dateInterval(of: component, for: record.minute)?.start ?? record.minute
        }
        return bucketStarts(by: component, in: interval, calendar: calendar).map { start in
            PostureBucket(start: start, summary: PostureSummary(records: recordsByStart[start] ?? []))
        }
    }

    private static func bucketStarts(by component: Calendar.Component, in interval: DateInterval, calendar: Calendar) -> [Date] {
        var starts: [Date] = []
        var bucket = calendar.dateInterval(of: component, for: interval.start)
        while let current = bucket, current.start < interval.end {
            starts.append(current.start)
            bucket = calendar.dateInterval(of: component, for: current.end)
        }
        return starts
    }
}
