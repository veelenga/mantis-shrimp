import Foundation

public struct PostureBucket: Equatable {
    public let start: Date
    public let summary: PostureSummary

    public init(start: Date, summary: PostureSummary) {
        self.start = start
        self.summary = summary
    }
}
