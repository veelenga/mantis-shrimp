import PostureCore
import SwiftUI

struct IssueBreakdownView: View {
    let summary: PostureSummary

    var body: some View {
        if summary.rankedIssues.isEmpty {
            Text("No posture issues recorded in this period.")
                .foregroundStyle(.secondary)
        } else {
            issueRows
        }
    }

    private var issueRows: some View {
        Grid(alignment: .leading, horizontalSpacing: StatsLayout.columnSpacing, verticalSpacing: StatsLayout.itemSpacing) {
            ForEach(summary.rankedIssues, id: \.self) { issue in
                GridRow {
                    Text(issue.title)
                    IssueBar(fraction: share(of: issue))
                    Text(DurationText.format(summary.seconds(for: issue)))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                }
            }
        }
    }

    private func share(of issue: PostureIssue) -> Double {
        guard let topIssue = summary.topIssue else { return 0 }
        return summary.seconds(for: issue) / summary.seconds(for: topIssue)
    }
}
