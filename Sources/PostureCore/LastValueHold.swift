import Foundation

public struct LastValueHold<Value> {
    private let duration: TimeInterval
    private var last: (value: Value, seenAt: TimeInterval)?

    public init(duration: TimeInterval) {
        self.duration = duration
    }

    public mutating func update(_ value: Value?, at time: TimeInterval) -> Value? {
        if let value {
            last = (value, time)
            return value
        }
        guard let last, time - last.seenAt < duration else {
            self.last = nil
            return nil
        }
        return last.value
    }

    public mutating func reset() {
        last = nil
    }
}
