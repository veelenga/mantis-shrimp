import Foundation
import PostureCore

enum PostureReportText {
    struct Input {
        let range: StatsRange
        let report: PostureReport
        let generatedAt: Date
        let calendar: Calendar
    }

    private static let minutesFormat = "%.1f"
    private static let noValueText = "n/a"
    private static let issueSeparator = "; "

    private static func dayFormat(_ calendar: Calendar) -> Date.FormatStyle {
        Date.FormatStyle(calendar: calendar, timeZone: calendar.timeZone).day().month(.abbreviated).year()
    }

    private static func hourFormat(_ calendar: Calendar) -> Date.FormatStyle {
        dayFormat(calendar).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
    }

    static func markdown(_ input: Input) -> String {
        [
            header(input),
            totals(input.report.summary),
            issueTable(input.report.summary),
            bucketTable(input),
        ].joined(separator: "\n\n")
    }

    private static func header(_ input: Input) -> String {
        let calendar = input.calendar
        let interval = input.report.interval
        return """
        # Posture report (\(input.range.title))

        Generated \(input.generatedAt.formatted(hourFormat(calendar))) by MantisShrimp, a macOS app that reads posture from the webcam with Apple Vision.
        Range: \(interval.start.formatted(dayFormat(calendar))) to \(interval.end.addingTimeInterval(-1).formatted(dayFormat(calendar))).

        How to read this: "monitored" is time the app could see the shoulders. "good" is monitored time with no issue. "not measured" is time the app ran but could not read posture (nobody in frame or calibrating). An issue counts only after it persisted for \(Int(MonitorTiming.Detection.onsetDelay)) seconds. Several issues can overlap, so issue times may add up to more than the monitored time. Left and right refer to the person's own body. Durations are in minutes.
        """
    }

    private static func totals(_ summary: PostureSummary) -> String {
        """
        ## Totals

        - Monitored: \(minutes(summary.monitoredSeconds)) min
        - Good posture: \(minutes(summary.goodSeconds)) min (\(percent(summary.goodFraction)))
        - Not measured: \(minutes(summary.unmeasuredSeconds)) min
        """
    }

    private static func issueTable(_ summary: PostureSummary) -> String {
        let title = "## Time per issue"
        guard !summary.rankedIssues.isEmpty else { return "\(title)\n\nNo issues recorded." }
        let rows = summary.rankedIssues.map { issue in
            let seconds = summary.seconds(for: issue)
            let share = summary.monitoredSeconds > 0 ? seconds / summary.monitoredSeconds : nil
            return [issue.title, minutes(seconds), percent(share)]
        }
        let table = MarkdownTable(
            columns: [.init("Issue"), .init("Minutes", alignment: .trailing), .init("Share of monitored", alignment: .trailing)],
            rows: rows
        )
        return "\(title)\n\n\(table.text)"
    }

    private static func bucketTable(_ input: Input) -> String {
        let format = input.range.bucketComponent == .hour ? hourFormat(input.calendar) : dayFormat(input.calendar)
        let rows = input.report.buckets.filter { $0.summary.trackedSeconds > 0 }.map { bucket in
            let summary = bucket.summary
            let issues = summary.rankedIssues.map { "\($0.title) \(minutes(summary.seconds(for: $0)))" }.joined(separator: issueSeparator)
            return [bucket.start.formatted(format), minutes(summary.monitoredSeconds), percent(summary.goodFraction), minutes(summary.unmeasuredSeconds), issues]
        }
        let table = MarkdownTable(
            columns: [
                .init("Start"),
                .init("Monitored min", alignment: .trailing),
                .init("Good", alignment: .trailing),
                .init("Not measured min", alignment: .trailing),
                .init("Issues (minutes)"),
            ],
            rows: rows
        )
        return "## \(input.range.reportBucketTitle)\n\n\(table.text)"
    }

    private static func minutes(_ seconds: Double) -> String {
        String(format: minutesFormat, seconds / TimeInterval.secondsPerMinute)
    }

    private static func percent(_ fraction: Double?) -> String {
        fraction.map(PercentText.plain) ?? noValueText
    }
}
