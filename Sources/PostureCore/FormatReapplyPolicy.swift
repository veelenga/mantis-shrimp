import CoreGraphics
import Foundation

public struct FormatReapplyPolicy {
    private static let minimumInterval: TimeInterval = 2
    private static let maximumAttempts = 5

    private var lastApplyAt: TimeInterval = 0
    private var attempts = 0

    public init() {}

    public mutating func shouldReapply(actual: CGSize, desired: CGSize, now: TimeInterval) -> Bool {
        guard actual != desired,
              now - lastApplyAt >= Self.minimumInterval,
              attempts < Self.maximumAttempts else { return false }
        attempts += 1
        return true
    }

    public mutating func recordApply(at time: TimeInterval) {
        lastApplyAt = time
    }

    public mutating func reset() {
        attempts = 0
    }
}
