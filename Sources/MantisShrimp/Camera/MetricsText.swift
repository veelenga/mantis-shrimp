import PostureCore

struct MetricRow: Equatable {
    let name: String
    let value: String
    let limit: String
    let isOverLimit: Bool
}

enum MetricsText {
    static let notAvailable = "–"

    static func rows(for analysis: FrameAnalysis) -> [MetricRow] {
        guard let deviations = analysis.deviations else { return [] }
        let limits = analysis.thresholds
        return [
            percentRow("Shoulders", deviations.shoulderTilt, limit: limits.shoulderTilt, symmetric: true),
            percentRow("Head tilt", deviations.headTilt, limit: limits.headTilt, symmetric: true),
            percentRow("Head drop", deviations.headDrop, limit: limits.headDrop, symmetric: false),
            ratioRow("Lean", deviations.leanRatio, limit: limits.leanInRatio),
            ratioRow("Head closer", deviations.headScaleRatio, limit: limits.headScaleRatio),
            percentRow("Ear lift", deviations.earLiftRise, limit: limits.earLift, symmetric: false),
        ]
    }

    static func issuesLine(for analysis: FrameAnalysis) -> String {
        guard analysis.deviations != nil else { return "Shoulders not in view" }
        guard !analysis.instantIssues.isEmpty else { return "Right now: good posture" }
        return "Right now: " + analysis.instantIssues.joinedTitles
    }

    private static func percentRow(_ name: String, _ value: Double?, limit: Double, symmetric: Bool) -> MetricRow {
        let limitText = String(format: symmetric ? "±%.1f%%" : "%.1f%%", limit * 100)
        guard let value else { return MetricRow(name: name, value: notAvailable, limit: limitText, isOverLimit: false) }
        let over = symmetric ? abs(value) > limit : value > limit
        return MetricRow(name: name, value: String(format: "%+.1f%%", value * 100), limit: limitText, isOverLimit: over)
    }

    private static func ratioRow(_ name: String, _ value: Double?, limit: Double) -> MetricRow {
        let limitText = String(format: "×%.2f", limit)
        guard let value else { return MetricRow(name: name, value: notAvailable, limit: limitText, isOverLimit: false) }
        return MetricRow(name: name, value: String(format: "×%.2f", value), limit: limitText, isOverLimit: value > limit)
    }
}
