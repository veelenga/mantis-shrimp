import Foundation

public struct SustainedIssueDetector {
    public private(set) var confirmed: Set<PostureIssue> = []

    private let onsetDelay: TimeInterval
    private let releaseDelay: TimeInterval
    private var presentSince: [PostureIssue: TimeInterval] = [:]
    private var absentSince: [PostureIssue: TimeInterval] = [:]

    public init(onsetDelay: TimeInterval, releaseDelay: TimeInterval) {
        self.onsetDelay = onsetDelay
        self.releaseDelay = releaseDelay
    }

    public mutating func update(_ observed: Set<PostureIssue>, at time: TimeInterval) -> Set<PostureIssue> {
        for issue in PostureIssue.allCases {
            if observed.contains(issue) {
                trackPresence(of: issue, at: time)
            } else {
                trackAbsence(of: issue, at: time)
            }
        }
        return confirmed
    }

    public mutating func reset() {
        confirmed = []
        presentSince = [:]
        absentSince = [:]
    }

    private mutating func trackPresence(of issue: PostureIssue, at time: TimeInterval) {
        absentSince[issue] = nil
        guard !confirmed.contains(issue) else { return }
        let since = presentSince[issue] ?? time
        presentSince[issue] = since
        if time - since >= onsetDelay {
            confirmed.insert(issue)
            presentSince[issue] = nil
        }
    }

    private mutating func trackAbsence(of issue: PostureIssue, at time: TimeInterval) {
        presentSince[issue] = nil
        guard confirmed.contains(issue) else { return }
        let since = absentSince[issue] ?? time
        absentSince[issue] = since
        if time - since >= releaseDelay {
            confirmed.remove(issue)
            absentSince[issue] = nil
        }
    }
}
