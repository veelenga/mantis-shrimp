import Foundation

public struct PostureSummary: Equatable {
    public let totals: PostureTotals

    public var monitoredSeconds: Double { totals.monitoredSeconds }
    public var goodSeconds: Double { totals.goodSeconds }
    public var unmeasuredSeconds: Double { totals.unmeasuredSeconds }
    public var issueSeconds: [PostureIssue: Double] { totals.issueSeconds }

    public init(records: [PostureMinuteRecord]) {
        totals = records.reduce(.zero) { $0.merged(with: $1.totals) }
    }

    public var trackedSeconds: Double {
        monitoredSeconds + unmeasuredSeconds
    }

    public var unmeasuredFraction: Double? {
        guard trackedSeconds > 0 else { return nil }
        return unmeasuredSeconds / trackedSeconds
    }

    public var goodFraction: Double? {
        guard monitoredSeconds > 0 else { return nil }
        return goodSeconds / monitoredSeconds
    }

    public var rankedIssues: [PostureIssue] {
        PostureIssue.allCases
            .filter { seconds(for: $0) > 0 }
            .sorted { seconds(for: $0) > seconds(for: $1) }
    }

    public var topIssue: PostureIssue? {
        rankedIssues.first
    }

    public func seconds(for issue: PostureIssue) -> Double {
        issueSeconds[issue, default: 0]
    }
}
