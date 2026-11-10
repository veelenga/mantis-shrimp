import SwiftUI

struct StatsContentView: View {
    let model: StatsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: StatsLayout.sectionSpacing) {
            SummaryTilesView(summary: model.report.summary)
            StatsSection(title: model.range.chartTitle) {
                GoodPostureChartView(report: model.report, component: model.range.bucketComponent)
            }
            StatsSection(title: "Time per issue") {
                IssueBreakdownView(summary: model.report.summary)
            }
        }
    }
}
