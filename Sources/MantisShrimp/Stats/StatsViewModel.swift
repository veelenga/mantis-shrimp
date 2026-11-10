import AppKit
import Foundation
import Observation
import PostureCore

@MainActor
@Observable
final class StatsViewModel {
    var range: StatsRange = .today
    private(set) var report = PostureReport.empty

    @ObservationIgnored private let store: PostureHistoryStore
    @ObservationIgnored private let calendar: Calendar

    init(store: PostureHistoryStore, calendar: Calendar = .current) {
        self.store = store
        self.calendar = calendar
    }

    var hasData: Bool {
        report.hasData
    }

    func resetHistory() {
        try? store.deleteAll()
        load()
    }

    func copyReport(now: Date = Date()) {
        let input = PostureReportText.Input(range: range, report: report, generatedAt: now, calendar: calendar)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(PostureReportText.markdown(input), forType: .string)
    }

    func load(now: Date = Date()) {
        let interval = range.interval(endingAt: now, calendar: calendar)
        report = PostureReport(records: records(in: interval), component: range.bucketComponent, interval: interval, calendar: calendar)
    }

    private func records(in interval: DateInterval) -> [PostureMinuteRecord] {
        (try? store.records(in: interval)) ?? []
    }
}
