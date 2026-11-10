import Foundation

struct Snooze {
    private var endsAt: TimeInterval?

    mutating func start(at time: TimeInterval, duration: TimeInterval) {
        endsAt = time + duration
    }

    func isActive(at time: TimeInterval) -> Bool {
        guard let endsAt else { return false }
        return time < endsAt
    }
}
