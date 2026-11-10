import CoreVideo
import PostureCore

final class LandmarksDetector {
    private let body = BodyLandmarksDetector()
    private let face = FaceLandmarksDetector()

    func detect(in pixelBuffer: CVPixelBuffer) -> BodyLandmarks? {
        guard let landmarks = body.detect(in: pixelBuffer) else { return nil }
        guard let faceLandmarks = face.detect(in: pixelBuffer) else { return landmarks }
        return landmarks.replacingHead(with: faceLandmarks)
    }
}
