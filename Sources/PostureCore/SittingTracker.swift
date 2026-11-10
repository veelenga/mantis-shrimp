import Foundation

public struct SittingTracker {
    private let breakDuration: TimeInterval
    private var sittingSince: TimeInterval?
    private var absentSince: TimeInterval?

    public init(breakDuration: TimeInterval) {
        self.breakDuration = breakDuration
    }

    public mutating func update(isPresent: Bool, at time: TimeInterval) -> TimeInterval {
        if isPresent {
            absentSince = nil
            sittingSince = sittingSince ?? time
        } else {
            let since = absentSince ?? time
            absentSince = since
            if time - since >= breakDuration {
                sittingSince = nil
            }
        }
        return sittingSince.map { time - $0 } ?? 0
    }

    public mutating func reset() {
        sittingSince = nil
        absentSince = nil
    }
}
