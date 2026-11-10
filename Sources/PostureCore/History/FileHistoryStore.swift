import Foundation

public final class FileHistoryStore: PostureHistoryStore {
    private static let fileExtension = "jsonl"

    private let directory: URL
    private let calendar: Calendar
    private let dayFormatter: DateFormatter
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(directory: URL, calendar: Calendar = .current) {
        self.directory = directory
        self.calendar = calendar
        dayFormatter = DateFormatter()
        dayFormatter.calendar = calendar
        dayFormatter.timeZone = calendar.timeZone
        dayFormatter.dateFormat = "yyyy-MM-dd"
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    public static var rootDirectory: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("MantisShrimp", isDirectory: true)
    }

    public static func defaultDirectory() -> URL {
        rootDirectory.appendingPathComponent("history", isDirectory: true)
    }

    public func append(_ record: PostureMinuteRecord) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var line = try encoder.encode(record)
        line.append(contentsOf: [UInt8(ascii: "\n")])
        let file = fileURL(for: record.minute)
        guard FileManager.default.fileExists(atPath: file.path) else {
            try line.write(to: file)
            return
        }
        let handle = try FileHandle(forWritingTo: file)
        defer { try? handle.close() }
        try handle.seekToEnd()
        try handle.write(contentsOf: line)
    }

    public func deleteAll() throws {
        let files = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        for file in files where file.pathExtension == Self.fileExtension {
            try FileManager.default.removeItem(at: file)
        }
    }

    public func records(in interval: DateInterval) throws -> [PostureMinuteRecord] {
        try days(in: interval)
            .flatMap(records(onDay:))
            .filter { interval.contains($0.minute) }
    }

    private func records(onDay day: Date) throws -> [PostureMinuteRecord] {
        let file = fileURL(for: day)
        guard let data = FileManager.default.contents(atPath: file.path) else { return [] }
        return data.split(separator: UInt8(ascii: "\n"))
            .compactMap { try? decoder.decode(PostureMinuteRecord.self, from: $0) }
    }

    private func days(in interval: DateInterval) -> [Date] {
        var days: [Date] = []
        var day = calendar.startOfDay(for: interval.start)
        while day <= interval.end {
            days.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }

    private func fileURL(for date: Date) -> URL {
        directory.appendingPathComponent(dayFormatter.string(from: date)).appendingPathExtension(Self.fileExtension)
    }
}
