import SwiftUI

struct IssueBar: View {
    private static let height: CGFloat = 10

    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(.fill.tertiary)
                Capsule().fill(.orange).frame(width: proxy.size.width * fraction)
            }
        }
        .frame(height: Self.height)
    }
}
