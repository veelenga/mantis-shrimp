import Charts
import PostureCore
import SwiftUI

struct GoodPostureChartView: View {
    private static let percentScale = 100.0
    private static let percentDomain = 0.0...100.0
    private static let percentTicks: [Double] = [0, 25, 50, 75, 100]
    private static let minimumHeight: CGFloat = 140

    let report: PostureReport
    let component: Calendar.Component

    var body: some View {
        Chart(monitoredBuckets, id: \.start) { bucket in
            BarMark(
                x: .value("Time", bucket.start, unit: component),
                y: .value("Good posture", goodPercent(of: bucket))
            )
            .foregroundStyle(Color.accentColor)
        }
        .chartXScale(domain: report.interval.start...report.interval.end)
        .chartXAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(collisionResolution: .disabled)
            }
        }
        .chartYScale(domain: Self.percentDomain)
        .chartYAxis {
            AxisMarks(values: Self.percentTicks) { value in
                AxisGridLine()
                AxisValueLabel { Text(percentLabel(value.as(Double.self))) }
            }
        }
        .frame(minHeight: Self.minimumHeight)
    }

    private var monitoredBuckets: [PostureBucket] {
        report.buckets.filter { $0.summary.goodFraction != nil }
    }

    private func goodPercent(of bucket: PostureBucket) -> Double {
        (bucket.summary.goodFraction ?? 0) * Self.percentScale
    }

    private func percentLabel(_ percent: Double?) -> String {
        "\(Int(percent ?? 0))%"
    }
}
