import Testing
@testable import PostureCore

struct PostureDeviationsTests {
    private let thresholds = PostureThresholds.standard

    @Test func deviationsAreRelativeToBaseline() {
        let baseline = PostureMetrics(shoulderTilt: 0.02, shoulderWidth: 0.4, headHeight: 0.6, headTilt: 0.01)
        let metrics = PostureMetrics(shoulderTilt: 0.05, shoulderWidth: 0.5, headHeight: 0.5, headTilt: -0.04)
        let deviations = PostureEvaluator(baseline: baseline, thresholds: thresholds).deviations(of: metrics)
        #expect(abs(deviations.shoulderTilt - 0.03) < 1e-9)
        #expect(abs((deviations.headTilt ?? 0) + 0.05) < 1e-9)
        #expect(abs((deviations.headDrop ?? 0) - 0.1) < 1e-9)
        #expect(abs((deviations.leanRatio ?? 0) - 1.25) < 1e-9)
    }

    @Test func withoutBaselineOnlyTiltsAreAvailable() {
        let metrics = PostureMetrics(shoulderTilt: 0.05, shoulderWidth: 0.5, headHeight: 0.5, headTilt: 0.02)
        let deviations = PostureEvaluator(baseline: nil, thresholds: thresholds).deviations(of: metrics)
        #expect(deviations.shoulderTilt == 0.05)
        #expect(deviations.headTilt == 0.02)
        #expect(deviations.headDrop == nil)
        #expect(deviations.leanRatio == nil)
    }

    @Test func initFromMetricsAndBaselineComputesEveryDeviation() {
        let baseline = PostureMetrics(shoulderTilt: 0.02, shoulderWidth: 0.4, headHeight: 0.6, headTilt: 0.01, headScale: 0.5, earLift: 0.1)
        let metrics = PostureMetrics(shoulderTilt: 0.05, shoulderWidth: 0.5, headHeight: 0.5, headTilt: -0.04, headScale: 0.6, earLift: 0.3)
        let deviations = PostureDeviations(metrics: metrics, baseline: baseline)
        #expect(abs(deviations.shoulderTilt - 0.03) < 1e-9)
        #expect(abs((deviations.headTilt ?? 0) + 0.05) < 1e-9)
        #expect(abs((deviations.headDrop ?? 0) - 0.1) < 1e-9)
        #expect(abs((deviations.leanRatio ?? 0) - 1.25) < 1e-9)
        #expect(abs((deviations.headScaleRatio ?? 0) - 1.2) < 1e-9)
        #expect(abs((deviations.earLiftRise ?? 0) - 0.2) < 1e-9)
    }

    @Test func zeroReferenceWidthYieldsNoLeanRatio() {
        let baseline = PostureMetrics(shoulderTilt: 0, shoulderWidth: 0)
        let metrics = PostureMetrics(shoulderTilt: 0, shoulderWidth: 0.5)
        #expect(PostureDeviations(metrics: metrics, baseline: baseline).leanRatio == nil)
    }
}
