import Testing
@testable import PostureCore

struct SustainedIssueDetectorTests {
    private func makeDetector() -> SustainedIssueDetector {
        SustainedIssueDetector(onsetDelay: 10, releaseDelay: 2)
    }

    @Test func issueIsConfirmedOnlyAfterOnsetDelay() {
        var detector = makeDetector()
        #expect(detector.update([.slouching], at: 0).isEmpty)
        #expect(detector.update([.slouching], at: 9.9).isEmpty)
        #expect(detector.update([.slouching], at: 10) == [.slouching])
    }

    @Test func briefMovementDoesNotTrigger() {
        var detector = makeDetector()
        _ = detector.update([.leftShoulderRaised], at: 0)
        _ = detector.update([], at: 5)
        #expect(detector.update([.leftShoulderRaised], at: 6).isEmpty)
        #expect(detector.update([.leftShoulderRaised], at: 15).isEmpty)
        #expect(detector.update([.leftShoulderRaised], at: 16) == [.leftShoulderRaised])
    }

    @Test func issuesAreTrackedIndependently() {
        var detector = makeDetector()
        _ = detector.update([.slouching], at: 0)
        _ = detector.update([.slouching, .leaningIn], at: 5)
        #expect(detector.update([.slouching, .leaningIn], at: 10) == [.slouching])
        #expect(detector.update([.slouching, .leaningIn], at: 15) == [.slouching, .leaningIn])
    }

    @Test func issueClearsAfterReleaseDelay() {
        var detector = makeDetector()
        _ = detector.update([.slouching], at: 0)
        _ = detector.update([.slouching], at: 10)
        #expect(detector.update([], at: 11) == [.slouching])
        #expect(detector.update([], at: 13).isEmpty)
    }

    @Test func resetClearsEverything() {
        var detector = makeDetector()
        _ = detector.update([.slouching], at: 0)
        _ = detector.update([.slouching], at: 10)
        detector.reset()
        #expect(detector.confirmed.isEmpty)
    }
}
