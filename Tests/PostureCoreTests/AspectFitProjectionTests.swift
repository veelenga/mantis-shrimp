import CoreGraphics
import Testing
@testable import PostureCore

struct AspectFitProjectionTests {
    @Test func letterboxesWideFrameInsideTallBounds() {
        let projection = AspectFitProjection(frameSize: CGSize(width: 640, height: 480), bounds: CGRect(x: 0, y: 0, width: 320, height: 400), mirrored: false)
        #expect(projection.videoRect == CGRect(x: 0, y: 80, width: 320, height: 240))
        #expect(projection.point(CGPoint(x: 0.5, y: 0)) == CGPoint(x: 160, y: 80))
        #expect(projection.point(CGPoint(x: 1, y: 1)) == CGPoint(x: 320, y: 320))
    }

    @Test func mirroringFlipsHorizontallyOnly() {
        let projection = AspectFitProjection(frameSize: CGSize(width: 4, height: 3), bounds: CGRect(x: 0, y: 0, width: 400, height: 300), mirrored: true)
        #expect(projection.point(CGPoint(x: 0.25, y: 0.25)) == CGPoint(x: 300, y: 75))
    }

    @Test func degenerateFrameFillsBounds() {
        let bounds = CGRect(x: 10, y: 20, width: 100, height: 50)
        let projection = AspectFitProjection(frameSize: .zero, bounds: bounds, mirrored: false)
        #expect(projection.videoRect == bounds)
    }
}
