import Foundation
import Testing
@testable import PostureCore

struct PostureMinuteRecordCodingTests {
    @Test func encodesFlatKeys() throws {
        let record = PostureMinuteRecord(
            minute: Date(timeIntervalSince1970: 1_794_564_000),
            monitoredSeconds: 30,
            goodSeconds: 20,
            unmeasuredSeconds: 5,
            issueSeconds: [.slouching: 10]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys

        let json = try String(decoding: encoder.encode(record), as: UTF8.self)

        #expect(json == #"{"goodSeconds":20,"issueSeconds":["slouching",10],"minute":"2026-11-13T10:00:00Z","monitoredSeconds":30,"unmeasuredSeconds":5}"#)
    }
}
