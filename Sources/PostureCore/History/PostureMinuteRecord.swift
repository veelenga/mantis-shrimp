import Foundation

public struct PostureMinuteRecord: Codable, Equatable {
    public let minute: Date
    public private(set) var totals: PostureTotals

    public var monitoredSeconds: Double { totals.monitoredSeconds }
    public var goodSeconds: Double { totals.goodSeconds }
    public var unmeasuredSeconds: Double { totals.unmeasuredSeconds }
    public var issueSeconds: [PostureIssue: Double] { totals.issueSeconds }

    private enum CodingKeys: String, CodingKey {
        case minute, monitoredSeconds, goodSeconds, unmeasuredSeconds, issueSeconds
    }

    public init(minute: Date, monitoredSeconds: Double = 0, goodSeconds: Double = 0, unmeasuredSeconds: Double = 0, issueSeconds: [PostureIssue: Double] = [:]) {
        self.minute = minute
        totals = PostureTotals(monitoredSeconds: monitoredSeconds, goodSeconds: goodSeconds, unmeasuredSeconds: unmeasuredSeconds, issueSeconds: issueSeconds)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        minute = try container.decode(Date.self, forKey: .minute)
        totals = PostureTotals(
            monitoredSeconds: try container.decode(Double.self, forKey: .monitoredSeconds),
            goodSeconds: try container.decode(Double.self, forKey: .goodSeconds),
            unmeasuredSeconds: try container.decodeIfPresent(Double.self, forKey: .unmeasuredSeconds) ?? 0,
            issueSeconds: try container.decode([PostureIssue: Double].self, forKey: .issueSeconds)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(minute, forKey: .minute)
        try container.encode(totals.monitoredSeconds, forKey: .monitoredSeconds)
        try container.encode(totals.goodSeconds, forKey: .goodSeconds)
        try container.encode(totals.unmeasuredSeconds, forKey: .unmeasuredSeconds)
        try container.encode(totals.issueSeconds, forKey: .issueSeconds)
    }

    public mutating func add(_ seconds: Double, sample: PostureSample) {
        switch sample {
        case .measured(let issues): addMeasured(seconds, issues: issues)
        case .unmeasured: totals.unmeasuredSeconds += seconds
        }
    }

    private mutating func addMeasured(_ seconds: Double, issues: Set<PostureIssue>) {
        totals.monitoredSeconds += seconds
        if issues.isEmpty {
            totals.goodSeconds += seconds
        }
        for issue in issues {
            totals.issueSeconds[issue, default: 0] += seconds
        }
    }
}
