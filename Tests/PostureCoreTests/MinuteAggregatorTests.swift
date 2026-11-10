import Foundation
import Testing
@testable import PostureCore

struct MinuteAggregatorTests {
    private let base = Date(timeIntervalSince1970: 1_700_000_040)
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    @Test func firstSampleOnlyStartsTheClock() {
        var aggregator = MinuteAggregator(calendar: calendar)
        #expect(aggregator.record(.measured([]), at: base) == nil)
        #expect(aggregator.flush()?.monitoredSeconds == nil)
    }

    @Test func accumulatesSecondsWithinAMinute() throws {
        var aggregator = MinuteAggregator(calendar: calendar)
        _ = aggregator.record(.measured([]), at: base)
        _ = aggregator.record(.measured([]), at: base.addingTimeInterval(0.5))
        _ = aggregator.record(.measured([.slouching]), at: base.addingTimeInterval(1.0))
        let flushed = aggregator.flush()
        let record = try #require(flushed)
        #expect(record.monitoredSeconds == 1.0)
        #expect(record.goodSeconds == 0.5)
        #expect(record.issueSeconds == [.slouching: 0.5])
    }

    @Test func emitsCompletedRecordWhenMinuteChanges() throws {
        var aggregator = MinuteAggregator(calendar: calendar)
        _ = aggregator.record(.measured([]), at: base.addingTimeInterval(59))
        _ = aggregator.record(.measured([]), at: base.addingTimeInterval(59.5))
        let rolled = aggregator.record(.measured([]), at: base.addingTimeInterval(60.5))
        let completed = try #require(rolled)
        #expect(completed.minute == base)
        #expect(completed.monitoredSeconds == 0.5)
        let remaining = aggregator.flush()
        #expect(remaining?.minute == base.addingTimeInterval(60))
    }

    @Test func unmeasuredTimeIsKeptSeparately() throws {
        var aggregator = MinuteAggregator(calendar: calendar)
        _ = aggregator.record(.unmeasured, at: base)
        _ = aggregator.record(.unmeasured, at: base.addingTimeInterval(1))
        _ = aggregator.record(.measured([]), at: base.addingTimeInterval(1.5))
        let flushed = aggregator.flush()
        #expect(flushed?.unmeasuredSeconds == 1.0)
        #expect(flushed?.monitoredSeconds == 0.5)
    }

    @Test func gapsAreNotCounted() throws {
        var aggregator = MinuteAggregator(calendar: calendar)
        _ = aggregator.record(.measured([]), at: base)
        aggregator.markGap()
        _ = aggregator.record(.measured([]), at: base.addingTimeInterval(20))
        _ = aggregator.record(.measured([]), at: base.addingTimeInterval(30))
        let flushed = aggregator.flush()
        #expect(flushed?.monitoredSeconds == MinuteAggregator.maxGap)
    }
}
