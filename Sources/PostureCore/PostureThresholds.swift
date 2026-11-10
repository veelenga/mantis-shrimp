public struct PostureThresholds: Equatable {
    public static let standard = PostureThresholds(
        shoulderTilt: 0.045,
        headTilt: 0.12,
        headDrop: 0.10,
        leanInRatio: 1.15,
        headScaleRatio: 1.12,
        earLift: 0.20
    )

    public var shoulderTilt: Double
    public var headTilt: Double
    public var headDrop: Double
    public var leanInRatio: Double
    public var headScaleRatio: Double
    public var earLift: Double

    public init(shoulderTilt: Double, headTilt: Double, headDrop: Double, leanInRatio: Double, headScaleRatio: Double, earLift: Double) {
        self.shoulderTilt = shoulderTilt
        self.headTilt = headTilt
        self.headDrop = headDrop
        self.leanInRatio = leanInRatio
        self.headScaleRatio = headScaleRatio
        self.earLift = earLift
    }

    public func scaled(by factor: Double) -> PostureThresholds {
        PostureThresholds(
            shoulderTilt: shoulderTilt * factor,
            headTilt: headTilt * factor,
            headDrop: headDrop * factor,
            leanInRatio: Self.scaleRatio(leanInRatio, by: factor),
            headScaleRatio: Self.scaleRatio(headScaleRatio, by: factor),
            earLift: earLift * factor
        )
    }

    private static func scaleRatio(_ ratio: Double, by factor: Double) -> Double {
        1 + (ratio - 1) * factor
    }
}
