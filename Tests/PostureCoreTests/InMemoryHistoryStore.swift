import Foundation
@testable import PostureCore

final class InMemoryHistoryStore: PostureHistoryStore {
    private(set) var stored: [PostureMinuteRecord] = []

    func append(_ record: PostureMinuteRecord) throws {
        stored.append(record)
    }

    func records(in interval: DateInterval) throws -> [PostureMinuteRecord] {
        stored.filter { interval.contains($0.minute) }
    }

    func deleteAll() throws {
        stored.removeAll()
    }
}
