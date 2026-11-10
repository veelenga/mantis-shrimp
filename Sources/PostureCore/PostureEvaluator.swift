public struct PostureEvaluator {
    public let baseline: PostureMetrics?
    public let thresholds: PostureThresholds

    public init(baseline: PostureMetrics?, thresholds: PostureThresholds) {
        self.baseline = baseline
        self.thresholds = thresholds
    }

    public init(settings: MonitorSettings) {
        self.init(baseline: settings.baseline, thresholds: settings.sensitivity.thresholds)
    }

    public func evaluate(_ metrics: PostureMetrics) -> Set<PostureIssue> {
        let deviations = deviations(of: metrics)
        var issues = Set<PostureIssue>()
        issues.formUnion(shoulderIssue(deviations))
        issues.formUnion(headTiltIssue(deviations))
        issues.formUnion(forwardHeadIssue(deviations))
        issues.formUnion(slouchIssue(deviations))
        issues.formUnion(leanIssue(deviations))
        return issues
    }

    private func shoulderIssue(_ deviations: PostureDeviations) -> Set<PostureIssue> {
        if deviations.shoulderTilt > thresholds.shoulderTilt { return [.leftShoulderRaised] }
        if deviations.shoulderTilt < -thresholds.shoulderTilt { return [.rightShoulderRaised] }
        return []
    }

    private func headTiltIssue(_ deviations: PostureDeviations) -> Set<PostureIssue> {
        guard let headTilt = deviations.headTilt else { return [] }
        if headTilt > thresholds.headTilt { return [.headTiltedRight] }
        if headTilt < -thresholds.headTilt { return [.headTiltedLeft] }
        return []
    }

    private func forwardHeadIssue(_ deviations: PostureDeviations) -> Set<PostureIssue> {
        let headCloser = (deviations.headScaleRatio ?? 0) > thresholds.headScaleRatio
        let earsLifted = (deviations.earLiftRise ?? 0) > thresholds.earLift
        return headCloser || earsLifted ? [.headForward] : []
    }

    private func slouchIssue(_ deviations: PostureDeviations) -> Set<PostureIssue> {
        guard let headDrop = deviations.headDrop else { return [] }
        return headDrop > thresholds.headDrop ? [.slouching] : []
    }

    private func leanIssue(_ deviations: PostureDeviations) -> Set<PostureIssue> {
        guard let leanRatio = deviations.leanRatio else { return [] }
        return leanRatio > thresholds.leanInRatio ? [.leaningIn] : []
    }
}
