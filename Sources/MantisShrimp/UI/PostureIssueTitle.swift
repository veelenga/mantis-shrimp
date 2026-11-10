import PostureCore

extension PostureIssue {
    var title: String {
        switch self {
        case .leftShoulderRaised: "Left shoulder raised"
        case .rightShoulderRaised: "Right shoulder raised"
        case .headTiltedLeft: "Head tilted left"
        case .headTiltedRight: "Head tilted right"
        case .headForward: "Head forward"
        case .slouching: "Slouching"
        case .leaningIn: "Leaning toward the screen"
        }
    }
}

extension Set where Element == PostureIssue {
    var joinedTitles: String {
        PostureIssue.allCases
            .filter(contains)
            .map(\.title)
            .joined(separator: ", ")
    }
}
