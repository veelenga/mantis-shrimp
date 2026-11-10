import PostureCore
import Vision

final class FaceLandmarksDetector {
    private static let minimumConfidence: VNConfidence = 0.5

    private let request = VNDetectFaceLandmarksRequest()

    func detect(in pixelBuffer: CVPixelBuffer) -> FaceLandmarks? {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        guard (try? handler.perform([request])) != nil,
              let face = largestFace(in: request.results ?? []),
              let landmarks = face.landmarks,
              landmarks.confidence >= Self.minimumConfidence,
              let leftEye = landmarks.leftEye,
              let rightEye = landmarks.rightEye,
              let nose = landmarks.nose else {
            return nil
        }
        let box = face.boundingBox
        return FaceLandmarks(
            eyes: (center(of: leftEye, in: box), center(of: rightEye, in: box)),
            nose: center(of: nose, in: box)
        )
    }

    private func largestFace(in faces: [VNFaceObservation]) -> VNFaceObservation? {
        faces.max { $0.boundingBox.width < $1.boundingBox.width }
    }

    private func center(of region: VNFaceLandmarkRegion2D, in box: CGRect) -> CGPoint {
        let points = region.normalizedPoints
        let count = CGFloat(points.count)
        let mean = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x / count, y: $0.y + $1.y / count) }
        return CGPoint(x: box.minX + mean.x * box.width, y: box.minY + mean.y * box.height)
    }
}
