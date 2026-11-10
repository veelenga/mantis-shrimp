import Foundation

public struct MinuteAggregator {
    public static let maxGap: TimeInterval = 2

    private let calendar: Calendar
    private var current: PostureMinuteRecord?
    private var lastSampleAt: Date?

    public init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    public mutating func record(_ sample: PostureSample, at date: Date) -> PostureMinuteRecord? {
        defer { lastSampleAt = date }
        guard let last = lastSampleAt else { return nil }
        let elapsed = min(date.timeIntervalSince(last), Self.maxGap)
        guard elapsed > 0, let minute = calendar.dateInterval(of: .minute, for: date)?.start else { return nil }

        let completed = rollOver(to: minute)
        current?.add(elapsed, sample: sample)
        return completed
    }

    public mutating func markGap() {
        lastSampleAt = nil
    }

    public mutating func flush() -> PostureMinuteRecord? {
        defer { current = nil }
        markGap()
        return current
    }

    private mutating func rollOver(to minute: Date) -> PostureMinuteRecord? {
        guard current?.minute != minute else { return nil }
        defer { current = PostureMinuteRecord(minute: minute) }
        return current
    }
}
