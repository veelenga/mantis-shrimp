import Testing
@testable import PostureCore

struct BadTimeAccumulatorTests {
    @Test func capsEachSampleAtTheMaxGap() {
        var accumulator = BadTimeAccumulator()
        accumulator.record(hasIssues: true, at: 0, window: 100)
        accumulator.record(hasIssues: true, at: 30, window: 100)
        #expect(accumulator.totalSeconds == BadTimeAccumulator.maxSampleGap)
    }

    @Test func ignoresTimeWithoutIssues() {
        var accumulator = BadTimeAccumulator()
        accumulator.record(hasIssues: true, at: 0, window: 100)
        accumulator.record(hasIssues: false, at: 1, window: 100)
        #expect(accumulator.totalSeconds == 0)
    }

    @Test func dropsSamplesOlderThanTheWindow() {
        var accumulator = BadTimeAccumulator()
        accumulator.record(hasIssues: true, at: 0, window: 10)
        accumulator.record(hasIssues: true, at: 1, window: 10)
        accumulator.record(hasIssues: false, at: 20, window: 10)
        #expect(accumulator.totalSeconds == 0)
    }

    @Test func resetClearsEverything() {
        var accumulator = BadTimeAccumulator()
        accumulator.record(hasIssues: true, at: 0, window: 10)
        accumulator.record(hasIssues: true, at: 1, window: 10)
        accumulator.reset()
        accumulator.record(hasIssues: true, at: 2, window: 10)
        #expect(accumulator.totalSeconds == 0)
    }
}
