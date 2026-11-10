import SwiftUI

struct StatsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: StatsLayout.itemSpacing) {
            Text(title).font(.headline)
            content
        }
    }
}
