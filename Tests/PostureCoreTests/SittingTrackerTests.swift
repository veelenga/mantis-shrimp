import Testing
@testable import PostureCore

struct SittingTrackerTests {
    @Test func countsContinuousPresence() {
        var tracker = SittingTracker(breakDuration: 120)
        #expect(tracker.update(isPresent: true, at: 0) == 0)
        #expect(tracker.update(isPresent: true, at: 600) == 600)
    }

    @Test func shortAbsenceDoesNotResetTheClock() {
        var tracker = SittingTracker(breakDuration: 120)
        _ = tracker.update(isPresent: true, at: 0)
        #expect(tracker.update(isPresent: false, at: 100) == 100)
        #expect(tracker.update(isPresent: true, at: 200) == 200)
    }

    @Test func longAbsenceResetsAndRestartsOnReturn() {
        var tracker = SittingTracker(breakDuration: 120)
        _ = tracker.update(isPresent: true, at: 0)
        _ = tracker.update(isPresent: false, at: 1000)
        #expect(tracker.update(isPresent: false, at: 1120) == 0)
        #expect(tracker.update(isPresent: true, at: 1200) == 0)
        #expect(tracker.update(isPresent: true, at: 1260) == 60)
    }
}
