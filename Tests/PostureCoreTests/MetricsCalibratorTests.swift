import Testing
@testable import PostureCore

struct MetricsCalibratorTests {
    private func sample(_ tilt: Double, headHeight: Double? = nil) -> PostureMetrics {
        PostureMetrics(shoulderTilt: tilt, shoulderWidth: 0.4, headHeight: headHeight)
    }

    @Test func ignoresSamplesWhenNotStarted() {
        var calibrator = MetricsCalibrator(duration: 5)
        #expect(calibrator.add(sample(0.1), at: 0) == nil)
        #expect(!calibrator.isRunning)
    }

    @Test func returnsPerFieldMediansAfterDurationAndMinimumSamples() throws {
        var calibrator = MetricsCalibrator(duration: 5)
        calibrator.start(at: 0)
        let tilts = [0.01, 0.5, 0.02, 0.03, -0.1]
        for (index, tilt) in tilts.enumerated() {
            #expect(calibrator.add(sample(tilt, headHeight: index < 2 ? 0.6 : nil), at: Double(index)) == nil)
        }
        let result = calibrator.add(sample(0.02, headHeight: 0.7), at: 5)
        let baseline = try #require(result)
        #expect(baseline.shoulderTilt == 0.02)
        #expect(baseline.shoulderWidth == 0.4)
        #expect(baseline.headHeight == 0.6)
        #expect(baseline.headTilt == nil)
        #expect(!calibrator.isRunning)
    }

    @Test func waitsForMinimumSamplesEvenAfterDuration() {
        var calibrator = MetricsCalibrator(duration: 5)
        calibrator.start(at: 0)
        #expect(calibrator.add(sample(0.1), at: 6) == nil)
        #expect(calibrator.isRunning)
    }

    @Test func customMinimumSamplesLetsCalibrationFinishEarly() {
        var calibrator = MetricsCalibrator(duration: 5, minimumSamples: 1)
        calibrator.start(at: 0)
        #expect(calibrator.add(sample(0.1), at: 6) != nil)
    }
}
