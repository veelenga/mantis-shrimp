import Foundation
import Testing
@testable import PostureCore

struct FileHistoryStoreTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func makeStore() -> FileHistoryStore {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        return FileHistoryStore(directory: directory, calendar: calendar)
    }

    @Test func appendsAndReadsBackRecordsAcrossDays() throws {
        let store = makeStore()
        let day = calendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000))
        let first = PostureMinuteRecord(minute: day.addingTimeInterval(600), monitoredSeconds: 60, goodSeconds: 50, issueSeconds: [.slouching: 10])
        let second = PostureMinuteRecord(minute: day.addingTimeInterval(86_400 + 60), monitoredSeconds: 30, goodSeconds: 30)
        let outside = PostureMinuteRecord(minute: day.addingTimeInterval(3 * 86_400), monitoredSeconds: 5, goodSeconds: 5)
        try store.append(first)
        try store.append(second)
        try store.append(outside)

        let records = try store.records(in: DateInterval(start: day, duration: 2 * 86_400))
        #expect(records == [first, second])
    }

    @Test func recordsWithoutUnmeasuredFieldStillDecode() throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let legacy = Data(#"{"minute":"2026-11-09T10:00:00Z","monitoredSeconds":60,"goodSeconds":40,"issueSeconds":["slouching",20]}"#.utf8)
        let record = try decoder.decode(PostureMinuteRecord.self, from: legacy)
        #expect(record.unmeasuredSeconds == 0)
        #expect(record.issueSeconds == [.slouching: 20])
    }

    @Test func deleteAllRemovesEveryRecord() throws {
        let store = makeStore()
        let minute = Date(timeIntervalSince1970: 1_700_000_040)
        try store.append(PostureMinuteRecord(minute: minute, monitoredSeconds: 60, goodSeconds: 60))
        try store.deleteAll()
        #expect(try store.records(in: DateInterval(start: minute.addingTimeInterval(-60), duration: 120)).isEmpty)
        try store.append(PostureMinuteRecord(minute: minute, monitoredSeconds: 30, goodSeconds: 30))
        #expect(try store.records(in: DateInterval(start: minute.addingTimeInterval(-60), duration: 120)).count == 1)
    }

    @Test func deleteAllOnMissingDirectorySucceeds() throws {
        try makeStore().deleteAll()
    }

    @Test func missingDaysReadAsEmpty() throws {
        let store = makeStore()
        #expect(try store.records(in: DateInterval(start: Date(), duration: 60)).isEmpty)
    }
}
