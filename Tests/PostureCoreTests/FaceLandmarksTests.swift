import CoreGraphics
import Testing
@testable import PostureCore

struct FaceLandmarksTests {
    let face = FaceLandmarks(eyes: (CGPoint(x: 0.4, y: 0.5), CGPoint(x: 0.6, y: 0.5)), nose: CGPoint(x: 0.5, y: 0.45))

    @Test func assignsEyesToTheSameSideAsTheShoulders() {
        let body = BodyLandmarks(leftShoulder: CGPoint(x: 0.8, y: 0.3), rightShoulder: CGPoint(x: 0.2, y: 0.3), leftEye: CGPoint(x: 0.9, y: 0.9))
        let merged = body.replacingHead(with: face)
        #expect(merged.leftEye == CGPoint(x: 0.6, y: 0.5))
        #expect(merged.rightEye == CGPoint(x: 0.4, y: 0.5))
        #expect(merged.nose == face.nose)
    }

    @Test func followsMirroredShoulders() {
        let body = BodyLandmarks(leftShoulder: CGPoint(x: 0.2, y: 0.3), rightShoulder: CGPoint(x: 0.8, y: 0.3))
        let merged = body.replacingHead(with: face)
        #expect(merged.leftEye == CGPoint(x: 0.4, y: 0.5))
        #expect(merged.rightEye == CGPoint(x: 0.6, y: 0.5))
    }

    @Test func keepsShouldersAndEars() {
        let ear = CGPoint(x: 0.7, y: 0.6)
        let body = BodyLandmarks(leftShoulder: CGPoint(x: 0.8, y: 0.3), rightShoulder: CGPoint(x: 0.2, y: 0.3), leftEar: ear)
        let merged = body.replacingHead(with: face)
        #expect(merged.leftShoulder == body.leftShoulder)
        #expect(merged.leftEar == ear)
    }
}
