import CoreGraphics

public struct FaceLandmarks {
    public let eyes: (CGPoint, CGPoint)
    public let nose: CGPoint

    public init(eyes: (CGPoint, CGPoint), nose: CGPoint) {
        self.eyes = eyes
        self.nose = nose
    }
}

extension BodyLandmarks {
    public func replacingHead(with face: FaceLandmarks) -> BodyLandmarks {
        let eyesByX = [face.eyes.0, face.eyes.1].sorted { $0.x < $1.x }
        let leftIsGreaterX = leftShoulder.x > rightShoulder.x
        return BodyLandmarks(
            leftShoulder: leftShoulder,
            rightShoulder: rightShoulder,
            nose: face.nose,
            leftEye: leftIsGreaterX ? eyesByX[1] : eyesByX[0],
            rightEye: leftIsGreaterX ? eyesByX[0] : eyesByX[1],
            leftEar: leftEar,
            rightEar: rightEar
        )
    }
}
