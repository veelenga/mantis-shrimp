import Testing
@testable import PostureCore

struct AlertCenterTests {
    private let issues: Set<PostureIssue> = [.slouching]

    private func feedPostureIssues(_ center: inout AlertCenter, until end: Int) {
        for second in 0...end {
            center.updatePosture(hasIssues: true, at: Double(second))
        }
    }

    @Test func postureAlertAppearsAfterDelay() {
        var center = AlertCenter(alertDelay: .thirtySeconds)
        feedPostureIssues(&center, until: 10)
        #expect(center.currentAlert(for: issues, sittingMinutes: 0) == nil)
        feedPostureIssues(&center, until: 40)
        #expect(center.currentAlert(for: issues, sittingMinutes: 0) == .posture(issues))
    }

    @Test func postureAlertNeedsIssuesInPhase() {
        var center = AlertCenter(alertDelay: .thirtySeconds)
        feedPostureIssues(&center, until: 40)
        #expect(center.currentAlert(for: [], sittingMinutes: 0) == nil)
    }

    @Test func sittingAlertAppearsAtLimit() {
        var center = AlertCenter(alertDelay: .off)
        center.updateSitting(duration: MonitorTiming.Sitting.limit, at: 0)
        #expect(center.currentAlert(for: [], sittingMinutes: 50) == .sittingTooLong(minutes: 50))
    }

    @Test func snoozeSilencesOnlyThatAlert() {
        var center = AlertCenter(alertDelay: .thirtySeconds)
        feedPostureIssues(&center, until: 40)
        center.updateSitting(duration: MonitorTiming.Sitting.limit, at: 30)
        center.snooze(.posture(issues), at: 40)
        #expect(center.currentAlert(for: issues, sittingMinutes: 50) == .sittingTooLong(minutes: 50))
        center.updatePosture(hasIssues: true, at: 41)
        #expect(center.currentAlert(for: issues, sittingMinutes: 50) == .sittingTooLong(minutes: 50))
    }

    @Test func resetPostureKeepsSittingAlert() {
        var center = AlertCenter(alertDelay: .thirtySeconds)
        feedPostureIssues(&center, until: 40)
        center.updateSitting(duration: MonitorTiming.Sitting.limit, at: 30)
        center.resetPosture()
        #expect(center.currentAlert(for: issues, sittingMinutes: 50) == .sittingTooLong(minutes: 50))
        center.reset()
        #expect(center.currentAlert(for: issues, sittingMinutes: 50) == nil)
    }

    @Test func rebuildAppliesNewDelay() {
        var center = AlertCenter(alertDelay: .fiveMinutes)
        center.updatePosture(hasIssues: true, at: 0)
        center.rebuildPosture(for: .off)
        center.updatePosture(hasIssues: true, at: 600)
        #expect(center.currentAlert(for: issues, sittingMinutes: 0) == nil)
    }
}
