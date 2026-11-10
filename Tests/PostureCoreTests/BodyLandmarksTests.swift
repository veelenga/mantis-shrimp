import CoreGraphics
import Testing
@testable import PostureCore

struct BodyLandmarksTests {
    private let leftShoulder = CGPoint(x: 0.3, y: 0.2)
    private let rightShoulder = CGPoint(x: 0.7, y: 0.2)

    @Test func allPointsContainsOnlyShouldersWhenNothingElseDetected() {
        let landmarks = BodyLandmarks(leftShoulder: leftShoulder, rightShoulder: rightShoulder)
        #expect(landmarks.allPoints == [leftShoulder, rightShoulder])
    }

    @Test func allPointsKeepsDetectedPointsInOrder() {
        let nose = CGPoint(x: 0.5, y: 0.5)
        let rightEar = CGPoint(x: 0.6, y: 0.5)
        let landmarks = BodyLandmarks(leftShoulder: leftShoulder, rightShoulder: rightShoulder, nose: nose, rightEar: rightEar)
        #expect(landmarks.allPoints == [leftShoulder, rightShoulder, nose, rightEar])
    }
}
