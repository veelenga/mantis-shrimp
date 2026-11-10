import Testing
@testable import PostureCore

struct AlertPolicyTests {
    private func makePolicy() -> AlertPolicy {
        AlertPolicy(threshold: 60, window: 120, snoozeDuration: 300)
    }

    private func run(_ policy: inout AlertPolicy, hasIssues: Bool, from start: Double, to end: Double, step: Double = 0.5) -> Bool {
        var result = false
        var time = start
        while time <= end {
            result = policy.update(hasIssues: hasIssues, at: time)
            time += step
        }
        return result
    }

    @Test func alertsAfterEnoughBadTime() {
        var policy = makePolicy()
        #expect(run(&policy, hasIssues: true, from: 0, to: 59) == false)
        #expect(run(&policy, hasIssues: true, from: 59.5, to: 61) == true)
    }

    @Test func badTimeAccumulatesAcrossTrackingGaps() {
        var policy = makePolicy()
        _ = run(&policy, hasIssues: true, from: 0, to: 40)
        #expect(run(&policy, hasIssues: true, from: 55, to: 76) == true)
    }

    @Test func goodPostureHidesTheAlertButKeepsTheBudgetForAWhile() {
        var policy = makePolicy()
        _ = run(&policy, hasIssues: true, from: 0, to: 61)
        #expect(policy.update(hasIssues: false, at: 62) == false)
        #expect(policy.update(hasIssues: true, at: 70) == true)
    }

    @Test func oldBadTimeFallsOutOfTheWindow() {
        var policy = makePolicy()
        _ = run(&policy, hasIssues: true, from: 0, to: 50)
        _ = run(&policy, hasIssues: false, from: 50.5, to: 180)
        #expect(policy.update(hasIssues: true, at: 181) == false)
        #expect(policy.badSeconds <= 1)
    }

    @Test func zeroThresholdAlertsImmediately() {
        var policy = AlertPolicy(threshold: 0, window: 60, snoozeDuration: 60)
        #expect(policy.update(hasIssues: true, at: 0) == true)
        #expect(policy.update(hasIssues: false, at: 1) == false)
    }

    @Test func snoozeSilencesUntilItExpires() {
        var policy = makePolicy()
        _ = run(&policy, hasIssues: true, from: 0, to: 61)
        policy.snooze(at: 61)
        #expect(policy.isAlerting == false)
        #expect(run(&policy, hasIssues: true, from: 61.5, to: 360.5) == false)
        #expect(policy.update(hasIssues: true, at: 361) == true)
    }
}
