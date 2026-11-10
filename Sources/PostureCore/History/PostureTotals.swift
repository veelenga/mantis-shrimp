import Foundation

public struct PostureTotals: Equatable {
    public static let zero = PostureTotals()

    public var monitoredSeconds: Double
    public var goodSeconds: Double
    public var unmeasuredSeconds: Double
    public var issueSeconds: [PostureIssue: Double]

    public init(monitoredSeconds: Double = 0, goodSeconds: Double = 0, unmeasuredSeconds: Double = 0, issueSeconds: [PostureIssue: Double] = [:]) {
        self.monitoredSeconds = monitoredSeconds
        self.goodSeconds = goodSeconds
        self.unmeasuredSeconds = unmeasuredSeconds
        self.issueSeconds = issueSeconds
    }

    public func merged(with other: PostureTotals) -> PostureTotals {
        PostureTotals(
            monitoredSeconds: monitoredSeconds + other.monitoredSeconds,
            goodSeconds: goodSeconds + other.goodSeconds,
            unmeasuredSeconds: unmeasuredSeconds + other.unmeasuredSeconds,
            issueSeconds: issueSeconds.merging(other.issueSeconds, uniquingKeysWith: +)
        )
    }
}
