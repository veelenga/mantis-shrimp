import AppKit
import PostureCore

final class LandmarkOverlay: CALayer {
    private static let lineWidth: CGFloat = 3
    private static let pointRadius: CGFloat = 5
    private static let goodColor = PostureTint.good.color.cgColor
    private static let issueColor = PostureTint.issue.color.cgColor

    private let lines = CAShapeLayer()
    private let points = CAShapeLayer()

    override init() {
        super.init()
        lines.lineWidth = Self.lineWidth
        lines.fillColor = nil
        addSublayer(lines)
        addSublayer(points)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func render(_ analysis: FrameAnalysis, mirrored: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }

        guard let landmarks = analysis.landmarks else {
            lines.path = nil
            points.path = nil
            return
        }
        let color = analysis.instantIssues.isEmpty ? Self.goodColor : Self.issueColor
        let projection = AspectFitProjection(frameSize: analysis.frameSize, bounds: bounds, mirrored: mirrored)
        let convert = projection.point
        lines.strokeColor = color
        lines.path = Self.linesPath(landmarks, convert: convert)
        points.fillColor = color
        points.path = Self.pointsPath(landmarks, convert: convert)
    }

    private static func linesPath(_ landmarks: BodyLandmarks, convert: (CGPoint) -> CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: convert(landmarks.leftShoulder))
        path.addLine(to: convert(landmarks.rightShoulder))
        if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
            path.move(to: convert(leftEye))
            path.addLine(to: convert(rightEye))
        }
        return path
    }

    private static func pointsPath(_ landmarks: BodyLandmarks, convert: (CGPoint) -> CGPoint) -> CGPath {
        let path = CGMutablePath()
        for point in landmarks.allPoints {
            path.addEllipse(in: CGRect(center: convert(point), radius: pointRadius))
        }
        return path
    }
}
