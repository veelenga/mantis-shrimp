import Foundation
import PostureCore

final class PostureRecorder {
    private let store: PostureHistoryStore
    private var aggregator = MinuteAggregator()

    init(store: PostureHistoryStore) {
        self.store = store
    }

    func record(_ sample: PostureSample, at date: Date = Date()) {
        persist(aggregator.record(sample, at: date))
    }

    func flush() {
        persist(aggregator.flush())
    }

    private func persist(_ record: PostureMinuteRecord?) {
        guard let record else { return }
        try? store.append(record)
    }
}
