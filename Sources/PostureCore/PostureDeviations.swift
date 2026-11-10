public struct PostureDeviations: Equatable {
    public var shoulderTilt: Double
    public var headTilt: Double?
    public var headDrop: Double?
    public var leanRatio: Double?
    public var headScaleRatio: Double?
    public var earLiftRise: Double?

    public init(
        shoulderTilt: Double,
        headTilt: Double? = nil,
        headDrop: Double? = nil,
        leanRatio: Double? = nil,
        headScaleRatio: Double? = nil,
        earLiftRise: Double? = nil
    ) {
        self.shoulderTilt = shoulderTilt
        self.headTilt = headTilt
        self.headDrop = headDrop
        self.leanRatio = leanRatio
        self.headScaleRatio = headScaleRatio
        self.earLiftRise = earLiftRise
    }

    public init(metrics: PostureMetrics, baseline: PostureMetrics?) {
        self.init(
            shoulderTilt: metrics.shoulderTilt - (baseline?.shoulderTilt ?? 0),
            headTilt: metrics.headTilt.map { $0 - (baseline?.headTilt ?? 0) },
            headDrop: Self.drop(from: baseline?.headHeight, to: metrics.headHeight),
            leanRatio: Self.ratio(of: metrics.shoulderWidth, to: baseline?.shoulderWidth),
            headScaleRatio: Self.ratio(of: metrics.headScale, to: baseline?.headScale),
            earLiftRise: Self.rise(from: baseline?.earLift, to: metrics.earLift)
        )
    }

    private static func drop(from reference: Double?, to value: Double?) -> Double? {
        guard let reference, let value else { return nil }
        return reference - value
    }

    private static func rise(from reference: Double?, to value: Double?) -> Double? {
        guard let reference, let value else { return nil }
        return value - reference
    }

    private static func ratio(of value: Double?, to reference: Double?) -> Double? {
        guard let reference, reference > 0, let value else { return nil }
        return value / reference
    }
}

extension PostureEvaluator {
    public func deviations(of metrics: PostureMetrics) -> PostureDeviations {
        PostureDeviations(metrics: metrics, baseline: baseline)
    }
}
