import Testing
@testable import PostureCore

struct AlertDelayTests {
    @Test func windowIsThreeTimesTheBadTime() {
        for delay in AlertDelay.allCases where delay.isEnabled {
            let schedule = delay.schedule
            #expect(schedule?.window == schedule.map { $0.badTime * AlertDelay.Schedule.windowToBadTimeRatio })
        }
    }

    @Test func offHasNoDelayAndNeverAlerts() {
        #expect(!AlertDelay.off.isEnabled)
        #expect(AlertDelay.off.schedule == nil)
        var policy = AlertPolicy(delay: .off, snoozeDuration: 10)
        var alerted = false
        for second in 0...600 {
            alerted = policy.update(hasIssues: true, at: Double(second))
        }
        #expect(!alerted)
        #expect(policy.badSeconds == 0)
    }

    @Test func policyAlertsAfterTheChosenDelay() {
        var policy = AlertPolicy(delay: .twoMinutes, snoozeDuration: 10)
        var alerted = false
        for second in 0...120 {
            alerted = policy.update(hasIssues: true, at: Double(second))
        }
        #expect(alerted)
        var early = AlertPolicy(delay: .twoMinutes, snoozeDuration: 10)
        var earlyAlert = false
        for second in 0...100 {
            earlyAlert = early.update(hasIssues: true, at: Double(second))
        }
        #expect(!earlyAlert)
    }
}
