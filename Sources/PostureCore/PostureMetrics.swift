import CoreGraphics
import Foundation

/// Lengths are fractions of shoulder width, so distance from the camera cancels out.
/// Tilts are positive when the person's left side sits higher than the right.
public struct PostureMetrics: Codable, Equatable {
    public var shoulderTilt: Double
    public var shoulderWidth: Double
    public var headHeight: Double?
    public var headTilt: Double?
    public var headScale: Double?
    public var earLift: Double?

    public init(
        shoulderTilt: Double,
        shoulderWidth: Double,
        headHeight: Double? = nil,
        headTilt: Double? = nil,
        headScale: Double? = nil,
        earLift: Double? = nil
    ) {
        self.shoulderTilt = shoulderTilt
        self.shoulderWidth = shoulderWidth
        self.headHeight = headHeight
        self.headTilt = headTilt
        self.headScale = headScale
        self.earLift = earLift
    }

    public init?(landmarks: BodyLandmarks) {
        let width = landmarks.leftShoulder.distance(to: landmarks.rightShoulder)
        guard width > 0 else { return nil }
        let eyeDistance = Self.eyeDistance(landmarks)

        shoulderWidth = width
        shoulderTilt = (landmarks.leftShoulder.y - landmarks.rightShoulder.y) / width
        headHeight = Self.headHeight(landmarks, shoulderWidth: width)
        headTilt = Self.headTilt(landmarks, eyeDistance: eyeDistance)
        headScale = eyeDistance.map { $0 / width }
        earLift = Self.earLift(landmarks, eyeDistance: eyeDistance)
    }

    private static func eyeDistance(_ landmarks: BodyLandmarks) -> Double? {
        guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else { return nil }
        let distance = leftEye.distance(to: rightEye)
        return distance > 0 ? distance : nil
    }

    private static func headHeight(_ landmarks: BodyLandmarks, shoulderWidth: Double) -> Double? {
        let shoulderMidY = (landmarks.leftShoulder.y + landmarks.rightShoulder.y) / 2
        return landmarks.nose.map { ($0.y - shoulderMidY) / shoulderWidth }
    }

    private static func headTilt(_ landmarks: BodyLandmarks, eyeDistance: Double?) -> Double? {
        guard let eyeDistance, let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye else { return nil }
        return (leftEye.y - rightEye.y) / eyeDistance
    }

    private static func earLift(_ landmarks: BodyLandmarks, eyeDistance: Double?) -> Double? {
        guard let eyeDistance, let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye, !landmarks.ears.isEmpty else {
            return nil
        }
        let eyeLevel = (leftEye.y + rightEye.y) / 2
        let earLevel = landmarks.ears.map(\.y).reduce(0, +) / Double(landmarks.ears.count)
        return (earLevel - eyeLevel) / eyeDistance
    }
}
