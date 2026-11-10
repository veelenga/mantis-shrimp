import CoreImage
import PostureCore
import Vision

final class BodyLandmarksDetector {
    private static let minimumConfidence: VNConfidence = 0.3
    private static let canvasWidth: CGFloat = 448
    private static let canvasColor = CIColor(red: 0.5, green: 0.5, blue: 0.5)
    // The pose model loses the shoulders when a torso fills the frame; shrinking it into a padded canvas restores them.
    private static let padding = PaddedFrameProjection(scale: 0.4, topInset: 0.05)

    private let request = VNDetectHumanBodyPoseRequest()

    func detect(in pixelBuffer: CVPixelBuffer) -> BodyLandmarks? {
        let handler = VNImageRequestHandler(ciImage: paddedImage(from: pixelBuffer), orientation: .up)
        guard (try? handler.perform([request])) != nil,
              let body = request.results?.first,
              let leftShoulder = location(of: .leftShoulder, in: body),
              let rightShoulder = location(of: .rightShoulder, in: body) else {
            return nil
        }
        return BodyLandmarks(
            leftShoulder: leftShoulder,
            rightShoulder: rightShoulder,
            nose: location(of: .nose, in: body),
            leftEye: location(of: .leftEye, in: body),
            rightEye: location(of: .rightEye, in: body),
            leftEar: location(of: .leftEar, in: body),
            rightEar: location(of: .rightEar, in: body)
        )
    }

    private func paddedImage(from pixelBuffer: CVPixelBuffer) -> CIImage {
        let source = CIImage(cvPixelBuffer: pixelBuffer)
        let canvas = CGSize(
            width: Self.canvasWidth,
            height: Self.canvasWidth * source.extent.height / source.extent.width
        )
        let target = Self.padding.frameRect(in: canvas)
        let scale = target.width / source.extent.width
        let placed = source
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            .transformed(by: CGAffineTransform(translationX: target.minX, y: target.minY))
        let background = CIImage(color: Self.canvasColor).cropped(to: CGRect(origin: .zero, size: canvas))
        return placed.composited(over: background)
    }

    private func location(of joint: VNHumanBodyPoseObservation.JointName, in body: VNHumanBodyPoseObservation) -> CGPoint? {
        guard let point = try? body.recognizedPoint(joint), point.confidence >= Self.minimumConfidence else {
            return nil
        }
        return Self.padding.sourcePoint(fromPadded: point.location)
    }
}
