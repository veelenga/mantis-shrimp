import SwiftUI

struct SummaryTile: View {
    private static let valueScaleFactor = 0.7

    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: StatsLayout.itemSpacing) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(Self.valueScaleFactor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(StatsLayout.tilePadding)
        .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: StatsLayout.cornerRadius))
    }
}
