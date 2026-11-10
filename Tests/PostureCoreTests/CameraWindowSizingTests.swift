import CoreGraphics
import Testing
@testable import PostureCore

struct CameraWindowSizingTests {
    @Test func initialSizeMatchesDefaultLandscapeRatio() {
        #expect(CameraWindowSizing.initialContentSize == CGSize(width: 640, height: 480 + 116))
    }

    @Test func landscapeFrameUsesLandscapeWidth() {
        let size = CameraWindowSizing.contentSize(for: CGSize(width: 1280, height: 720))
        #expect(size == CGSize(width: 640, height: 360 + 116))
    }

    @Test func portraitFrameUsesPortraitWidth() {
        let size = CameraWindowSizing.contentSize(for: CGSize(width: 720, height: 1280))
        #expect(size.width == 520)
        #expect(abs(size.height - (520 * 1280 / 720 + 116)) < 0.0001)
    }

    @Test func squareFrameIsTreatedAsLandscape() {
        #expect(CameraWindowSizing.contentSize(for: CGSize(width: 500, height: 500)).width == 640)
    }
}
