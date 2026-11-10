import CoreGraphics
import Testing
@testable import PostureCore

struct FormatReapplyPolicyTests {
    private let small = CGSize(width: 640, height: 480)
    private let large = CGSize(width: 1280, height: 960)

    @Test func matchingSizeNeverReapplies() {
        var policy = FormatReapplyPolicy()
        let shouldReapply = policy.shouldReapply(actual: small, desired: small, now: 100)
        #expect(!shouldReapply)
    }

    @Test func mismatchReappliesThenWaits() {
        var policy = FormatReapplyPolicy()
        let first = policy.shouldReapply(actual: small, desired: large, now: 100)
        policy.recordApply(at: 100)
        let tooSoon = policy.shouldReapply(actual: small, desired: large, now: 101)
        let later = policy.shouldReapply(actual: small, desired: large, now: 102)
        #expect(first)
        #expect(!tooSoon)
        #expect(later)
    }

    @Test func givesUpAfterMaximumAttemptsUntilReset() {
        var policy = FormatReapplyPolicy()
        for attempt in 0..<5 {
            let shouldReapply = policy.shouldReapply(actual: small, desired: large, now: Double(attempt) * 10 + 10)
            #expect(shouldReapply)
        }
        let exhausted = policy.shouldReapply(actual: small, desired: large, now: 1000)
        policy.reset()
        let afterReset = policy.shouldReapply(actual: small, desired: large, now: 1000)
        #expect(!exhausted)
        #expect(afterReset)
    }
}
