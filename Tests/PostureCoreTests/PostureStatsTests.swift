import Foundation
import PostureCore
import Testing

struct PostureStatsTests {
    private static let hoursPerDay = 24
    private static let daysPerWeek = 7

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    @Test func summingDuplicateMinutes() throws {
        let minute = try date(day: 9, hour: 10)
        let records = [
            PostureMinuteRecord(minute: minute, monitoredSeconds: 30, goodSeconds: 20, issueSeconds: [.slouching: 10]),
            PostureMinuteRecord(minute: minute, monitoredSeconds: 30, goodSeconds: 10, issueSeconds: [.slouching: 20, .leaningIn: 5]),
        ]

        let summary = PostureSummary(records: records)

        #expect(summary.monitoredSeconds == 60)
        #expect(summary.goodSeconds == 30)
        #expect(summary.issueSeconds == [.slouching: 30, .leaningIn: 5])
    }

    @Test func goodFractionIsNilWithoutMonitoring() throws {
        let idleRecord = PostureMinuteRecord(minute: try date(day: 9, hour: 10))

        #expect(PostureSummary(records: []).goodFraction == nil)
        #expect(PostureSummary(records: [idleRecord]).goodFraction == nil)
    }

    @Test func goodFractionDividesGoodByMonitoredTime() throws {
        let record = PostureMinuteRecord(minute: try date(day: 9, hour: 10), monitoredSeconds: 60, goodSeconds: 45)

        #expect(PostureSummary(records: [record]).goodFraction == 0.75)
    }

    @Test func topIssueIsTheLongestIssue() throws {
        let minute = try date(day: 9, hour: 10)
        let records = [
            PostureMinuteRecord(minute: minute, monitoredSeconds: 60, issueSeconds: [.headTiltedLeft: 25, .slouching: 20]),
            PostureMinuteRecord(minute: minute, monitoredSeconds: 60, issueSeconds: [.slouching: 15]),
        ]

        let summary = PostureSummary(records: records)

        #expect(summary.topIssue == .slouching)
        #expect(summary.rankedIssues == [.slouching, .headTiltedLeft])
    }

    @Test func topIssueIsNilWithoutIssues() throws {
        let record = PostureMinuteRecord(minute: try date(day: 9, hour: 10), monitoredSeconds: 60, goodSeconds: 60)

        #expect(PostureSummary(records: [record]).topIssue == nil)
    }

    @Test func hourlyBucketsCoverTheWholeDay() throws {
        let day = try date(day: 9)
        let interval = try #require(calendar.dateInterval(of: .day, for: day))
        let records = [
            PostureMinuteRecord(minute: try date(day: 9, hour: 9, minute: 5), monitoredSeconds: 60, goodSeconds: 60),
            PostureMinuteRecord(minute: try date(day: 9, hour: 9, minute: 40), monitoredSeconds: 60, goodSeconds: 30),
        ]

        let buckets = PostureStats.buckets(records, by: .hour, in: interval, calendar: calendar)

        #expect(buckets.count == Self.hoursPerDay)
        #expect(buckets.first?.start == day)
        #expect(buckets[9].summary.monitoredSeconds == 120)
        #expect(buckets[9].summary.goodFraction == 0.75)
        #expect(buckets.filter { $0.summary.goodFraction == nil }.count == Self.hoursPerDay - 1)
    }

    @Test func dailyBucketsIncludeEmptyDays() throws {
        let interval = DateInterval(start: try date(day: 3), end: try date(day: 10))
        let records = [
            PostureMinuteRecord(minute: try date(day: 3, hour: 8), monitoredSeconds: 60, goodSeconds: 60),
            PostureMinuteRecord(minute: try date(day: 5, hour: 14), monitoredSeconds: 60, goodSeconds: 15),
            PostureMinuteRecord(minute: try date(day: 12, hour: 9), monitoredSeconds: 60, goodSeconds: 60),
        ]

        let buckets = PostureStats.buckets(records, by: .day, in: interval, calendar: calendar)

        #expect(buckets.count == Self.daysPerWeek)
        #expect(buckets.map(\.start) == buckets.map(\.start).sorted())
        #expect(buckets[0].summary.goodFraction == 1)
        #expect(buckets[2].summary.goodFraction == 0.25)
        #expect(buckets.filter { $0.summary.monitoredSeconds == 0 }.count == Self.daysPerWeek - 2)
    }

    private func date(day: Int, hour: Int = 0, minute: Int = 0) throws -> Date {
        let components = DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute)
        return try #require(calendar.date(from: components))
    }
}

struct PostureSummaryUnmeasuredTests {
    @Test func unmeasuredTimeIsSummedAndExcludedFromGoodFraction() {
        let minute = Date(timeIntervalSince1970: 1_700_000_040)
        let records = [
            PostureMinuteRecord(minute: minute, monitoredSeconds: 30, goodSeconds: 30, unmeasuredSeconds: 30),
            PostureMinuteRecord(minute: minute.addingTimeInterval(60), unmeasuredSeconds: 60),
        ]
        let summary = PostureSummary(records: records)
        #expect(summary.unmeasuredSeconds == 90)
        #expect(summary.trackedSeconds == 120)
        #expect(summary.goodFraction == 1)
        #expect(summary.unmeasuredFraction == 0.75)
    }
}
