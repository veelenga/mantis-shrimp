import Testing
@testable import PostureCore

struct PostureEvaluatorTests {
    private let baseline = PostureMetrics(shoulderTilt: 0.02, shoulderWidth: 0.4, headHeight: 0.6, headTilt: 0, headScale: 0.2, earLift: 0.05)
    private let thresholds = PostureThresholds(shoulderTilt: 0.05, headTilt: 0.1, headDrop: 0.1, leanInRatio: 1.15, headScaleRatio: 1.12, earLift: 0.2)

    private var evaluator: PostureEvaluator {
        PostureEvaluator(baseline: baseline, thresholds: thresholds)
    }

    @Test func matchingBaselineIsGoodPosture() {
        #expect(evaluator.evaluate(baseline).isEmpty)
    }

    @Test func shoulderDeviationIsMeasuredFromBaseline() {
        var metrics = baseline
        metrics.shoulderTilt = 0.08
        #expect(evaluator.evaluate(metrics) == [.leftShoulderRaised])
        metrics.shoulderTilt = -0.04
        #expect(evaluator.evaluate(metrics) == [.rightShoulderRaised])
    }

    @Test func headTiltDirectionFollowsEyeLine() {
        var metrics = baseline
        metrics.headTilt = 0.2
        #expect(evaluator.evaluate(metrics) == [.headTiltedRight])
        metrics.headTilt = -0.2
        #expect(evaluator.evaluate(metrics) == [.headTiltedLeft])
    }

    @Test func headCloserThanShouldersIsHeadForward() {
        var metrics = baseline
        metrics.headScale = 0.23
        #expect(evaluator.evaluate(metrics) == [.headForward])
    }

    @Test func liftedEarsAreHeadForward() {
        var metrics = baseline
        metrics.earLift = 0.3
        #expect(evaluator.evaluate(metrics) == [.headForward])
    }

    @Test func wholeBodyCloserIsLeaningNotHeadForward() {
        var metrics = baseline
        metrics.shoulderWidth = 0.5
        metrics.headScale = 0.2
        #expect(evaluator.evaluate(metrics) == [.leaningIn])
    }

    @Test func droppedHeadIsSlouching() {
        var metrics = baseline
        metrics.headHeight = 0.45
        #expect(evaluator.evaluate(metrics) == [.slouching])
    }

    @Test func widerShouldersMeanLeaningIn() {
        var metrics = baseline
        metrics.shoulderWidth = 0.5
        #expect(evaluator.evaluate(metrics) == [.leaningIn])
    }

    @Test func issuesCombine() {
        var metrics = baseline
        metrics.shoulderTilt = 0.1
        metrics.headHeight = 0.4
        #expect(evaluator.evaluate(metrics) == [.leftShoulderRaised, .slouching])
    }

    @Test func withoutBaselineOnlyTiltsAreEvaluated() {
        let uncalibrated = PostureEvaluator(baseline: nil, thresholds: thresholds)
        let metrics = PostureMetrics(shoulderTilt: 0.01, shoulderWidth: 0.9, headHeight: 0.1, headTilt: 0.3)
        #expect(uncalibrated.evaluate(metrics) == [.headTiltedRight])
    }
}
