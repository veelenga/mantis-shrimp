import Foundation

struct BadTimeAccumulator {
    static let maxSampleGap: TimeInterval = 2

    private var samples: [(time: TimeInterval, seconds: TimeInterval)] = []
    private var lastUpdate: TimeInterval?

    var totalSeconds: TimeInterval {
        samples.reduce(0) { $0 + $1.seconds }
    }

    mutating func record(hasIssues: Bool, at time: TimeInterval, window: TimeInterval) {
        defer { lastUpdate = time }
        if hasIssues, let lastUpdate {
            let seconds = min(time - lastUpdate, Self.maxSampleGap)
            if seconds > 0 { samples.append((time, seconds)) }
        }
        samples.removeAll { time - $0.time > window }
    }

    mutating func reset() {
        samples = []
        lastUpdate = nil
    }
}
