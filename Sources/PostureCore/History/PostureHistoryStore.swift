import Foundation

public protocol PostureHistoryStore {
    func append(_ record: PostureMinuteRecord) throws
    func records(in interval: DateInterval) throws -> [PostureMinuteRecord]
    func deleteAll() throws
}
