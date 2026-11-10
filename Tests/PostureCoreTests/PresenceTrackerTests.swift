import Testing
@testable import PostureCore

struct PresenceTrackerTests {
    @Test func tracksSittingDurationAndMinutes() {
        var tracker = PresenceTracker()
        _ = tracker.update(isPresent: true, at: 0)
        let state = tracker.update(isPresent: true, at: 150)
        #expect(state.sittingDuration == 150)
        #expect(state.sittingMinutes == 2)
        #expect(state.absentSince == nil)
    }

    @Test func remembersWhenAbsenceStarted() {
        var tracker = PresenceTracker()
        _ = tracker.update(isPresent: false, at: 10)
        let state = tracker.update(isPresent: false, at: 40)
        #expect(state.absentSince == 10)
        #expect(state.absence(at: 40) == 30)
    }

    @Test func returningClearsAbsence() {
        var tracker = PresenceTracker()
        _ = tracker.update(isPresent: false, at: 10)
        let state = tracker.update(isPresent: true, at: 20)
        #expect(state.absence(at: 20) == nil)
    }

    @Test func resetForgetsSittingAndAbsence() {
        var tracker = PresenceTracker()
        _ = tracker.update(isPresent: true, at: 0)
        _ = tracker.update(isPresent: false, at: 5)
        tracker.reset()
        let state = tracker.update(isPresent: true, at: 100)
        #expect(state.sittingDuration == 0)
        #expect(state.absentSince == nil)
    }

    @Test func exposesLatestStateAndResetsIt() {
        var tracker = PresenceTracker()
        tracker.update(isPresent: false, at: 10)
        #expect(tracker.state.absentSince == 10)
        tracker.reset()
        #expect(tracker.state == .initial)
    }
}
