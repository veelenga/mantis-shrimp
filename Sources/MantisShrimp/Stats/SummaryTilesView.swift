import PostureCore
import SwiftUI

struct SummaryTilesView: View {
    private static let noDataText = "No data"
    private static let noIssueText = "None"

    let summary: PostureSummary

    var body: some View {
        HStack(spacing: StatsLayout.sectionSpacing) {
            SummaryTile(title: "Monitored time", value: DurationText.format(summary.monitoredSeconds))
            SummaryTile(title: "Good posture", value: goodPostureText)
            SummaryTile(title: "Most common issue", value: summary.topIssue?.title ?? Self.noIssueText)
            SummaryTile(title: "Not measured", value: unmeasuredText)
        }
    }

    private var unmeasuredText: String {
        guard let fraction = summary.unmeasuredFraction else { return Self.noDataText }
        return "\(DurationText.format(summary.unmeasuredSeconds)) (\(PercentText.format(fraction)))"
    }

    private var goodPostureText: String {
        guard let fraction = summary.goodFraction else { return Self.noDataText }
        return PercentText.format(fraction)
    }
}
