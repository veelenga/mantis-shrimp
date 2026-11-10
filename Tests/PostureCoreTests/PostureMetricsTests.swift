import CoreGraphics
import Testing
@testable import PostureCore

struct PostureMetricsTests {
    @Test func shoulderTiltIsPositiveWhenLeftShoulderIsHigher() throws {
        let landmarks = BodyLandmarks(leftShoulder: CGPoint(x: 0.3, y: 0.55), rightShoulder: CGPoint(x: 0.7, y: 0.5))
        let metrics = try #require(PostureMetrics(landmarks: landmarks))
        #expect(abs(metrics.shoulderTilt - 0.05 / metrics.shoulderWidth) < 1e-9)
        #expect(metrics.shoulderTilt > 0)
        #expect(metrics.headHeight == nil)
        #expect(metrics.headTilt == nil)
    }

    @Test func metricsAreNormalizedByShoulderWidth() throws {
        let near = try #require(PostureMetrics(landmarks: BodyLandmarks(
            leftShoulder: CGPoint(x: 0.2, y: 0.53), rightShoulder: CGPoint(x: 0.8, y: 0.5), nose: CGPoint(x: 0.5, y: 0.815))))
        let far = try #require(PostureMetrics(landmarks: BodyLandmarks(
            leftShoulder: CGPoint(x: 0.4, y: 0.51), rightShoulder: CGPoint(x: 0.6, y: 0.5), nose: CGPoint(x: 0.5, y: 0.605))))
        #expect(abs(near.shoulderTilt - far.shoulderTilt) < 1e-3)
        #expect(abs(try #require(near.headHeight) - (try #require(far.headHeight))) < 1e-3)
    }

    @Test func headTiltComesFromEyeLine() throws {
        let landmarks = BodyLandmarks(
            leftShoulder: CGPoint(x: 0.3, y: 0.5), rightShoulder: CGPoint(x: 0.7, y: 0.5),
            leftEye: CGPoint(x: 0.45, y: 0.72), rightEye: CGPoint(x: 0.55, y: 0.7))
        let metrics = try #require(PostureMetrics(landmarks: landmarks))
        #expect(try #require(metrics.headTilt) > 0)
    }

    @Test func headScaleAndEarLiftComeFromEyesAndEars() throws {
        let landmarks = BodyLandmarks(
            leftShoulder: CGPoint(x: 0.3, y: 0.5), rightShoulder: CGPoint(x: 0.7, y: 0.5),
            leftEye: CGPoint(x: 0.45, y: 0.7), rightEye: CGPoint(x: 0.55, y: 0.7),
            leftEar: CGPoint(x: 0.4, y: 0.72), rightEar: CGPoint(x: 0.6, y: 0.70))
        let metrics = try #require(PostureMetrics(landmarks: landmarks))
        #expect(abs(try #require(metrics.headScale) - 0.25) < 1e-9)
        #expect(abs(try #require(metrics.earLift) - 0.1) < 1e-9)
    }

    @Test func earLiftNeedsBothEyesAndAtLeastOneEar() throws {
        let landmarks = BodyLandmarks(
            leftShoulder: CGPoint(x: 0.3, y: 0.5), rightShoulder: CGPoint(x: 0.7, y: 0.5),
            leftEye: CGPoint(x: 0.45, y: 0.7), rightEye: CGPoint(x: 0.55, y: 0.7))
        let metrics = try #require(PostureMetrics(landmarks: landmarks))
        #expect(metrics.earLift == nil)
        #expect(metrics.headScale != nil)
    }

    @Test func degenerateShouldersProduceNoMetrics() {
        #expect(PostureMetrics(landmarks: BodyLandmarks(leftShoulder: .zero, rightShoulder: .zero)) == nil)
    }
}
