import Foundation
import Testing
@testable import PostureCore

struct PostureReportTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private var day: DateInterval {
        let start = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_794_564_000))
        return DateInterval(start: start, duration: 86_400)
    }

    @Test func buildsSummaryAndHourlyBucketsFromStore() throws {
        let store = InMemoryHistoryStore()
        try store.append(PostureMinuteRecord(minute: day.start.addingTimeInterval(3_600), monitoredSeconds: 60, goodSeconds: 40, issueSeconds: [.slouching: 20]))
        try store.append(PostureMinuteRecord(minute: day.start.addingTimeInterval(2 * 86_400), monitoredSeconds: 60, goodSeconds: 60))

        let report = PostureReport(records: try store.records(in: day), component: .hour, interval: day, calendar: calendar)

        #expect(report.summary.monitoredSeconds == 60)
        #expect(report.buckets.count == 24)
        #expect(report.hasData)
    }

    @Test func emptyReportHasNoData() {
        #expect(!PostureReport.empty.hasData)
    }

    @Test func unmeasuredOnlyTimeCountsAsData() {
        let record = PostureMinuteRecord(minute: day.start, unmeasuredSeconds: 30)
        let report = PostureReport(records: [record], component: .hour, interval: day, calendar: calendar)
        #expect(report.hasData)
    }

    @Test func totalsMergeAddsEveryField() {
        let first = PostureTotals(monitoredSeconds: 10, goodSeconds: 5, unmeasuredSeconds: 1, issueSeconds: [.slouching: 3])
        let second = PostureTotals(monitoredSeconds: 20, goodSeconds: 10, unmeasuredSeconds: 2, issueSeconds: [.slouching: 4, .leaningIn: 1])

        let merged = first.merged(with: second)

        #expect(merged == PostureTotals(monitoredSeconds: 30, goodSeconds: 15, unmeasuredSeconds: 3, issueSeconds: [.slouching: 7, .leaningIn: 1]))
    }
}
