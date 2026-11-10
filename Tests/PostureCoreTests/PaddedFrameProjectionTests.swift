import CoreGraphics
import Testing
@testable import PostureCore

struct PaddedFrameProjectionTests {
    let projection = PaddedFrameProjection(scale: 0.5, topInset: 0.1)

    @Test func placesFrameCenteredBelowTopInset() {
        let rect = projection.frameRect(in: CGSize(width: 400, height: 800))
        #expect(rect == CGRect(x: 100, y: 320, width: 200, height: 400))
    }

    @Test func mapsPaddedCornersBackToSourceCorners() {
        #expect(projection.sourcePoint(fromPadded: CGPoint(x: 0.25, y: 0.4)) == CGPoint(x: 0, y: 0))
        #expect(projection.sourcePoint(fromPadded: CGPoint(x: 0.75, y: 0.9)) == CGPoint(x: 1, y: 1))
    }

    @Test func mapsPaddedCenterToSourceCenter() {
        let center = projection.sourcePoint(fromPadded: CGPoint(x: 0.5, y: 0.65))
        #expect(abs(center.x - 0.5) < 1e-9)
        #expect(abs(center.y - 0.5) < 1e-9)
    }
}
