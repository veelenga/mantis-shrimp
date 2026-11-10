import CoreGraphics

public struct BodyLandmarks: Equatable {
    public let leftShoulder: CGPoint
    public let rightShoulder: CGPoint
    public let nose: CGPoint?
    public let leftEye: CGPoint?
    public let rightEye: CGPoint?
    public let leftEar: CGPoint?
    public let rightEar: CGPoint?

    public init(
        leftShoulder: CGPoint,
        rightShoulder: CGPoint,
        nose: CGPoint? = nil,
        leftEye: CGPoint? = nil,
        rightEye: CGPoint? = nil,
        leftEar: CGPoint? = nil,
        rightEar: CGPoint? = nil
    ) {
        self.leftShoulder = leftShoulder
        self.rightShoulder = rightShoulder
        self.nose = nose
        self.leftEye = leftEye
        self.rightEye = rightEye
        self.leftEar = leftEar
        self.rightEar = rightEar
    }

    public var allPoints: [CGPoint] {
        [leftShoulder, rightShoulder] + [nose, leftEye, rightEye, leftEar, rightEar].compactMap { $0 }
    }

    public var ears: [CGPoint] {
        [leftEar, rightEar].compactMap { $0 }
    }
}
