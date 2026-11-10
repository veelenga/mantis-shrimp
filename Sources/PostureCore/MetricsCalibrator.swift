import Foundation

public struct MetricsCalibrator {
    public static let defaultMinimumSamples = 5

    private let duration: TimeInterval
    private let minimumSamples: Int
    private var startedAt: TimeInterval?
    private var samples: [PostureMetrics] = []

    public init(duration: TimeInterval, minimumSamples: Int = MetricsCalibrator.defaultMinimumSamples) {
        self.duration = duration
        self.minimumSamples = minimumSamples
    }

    public var isRunning: Bool {
        startedAt != nil
    }

    public mutating func start(at time: TimeInterval) {
        startedAt = time
        samples = []
    }

    public mutating func cancel() {
        startedAt = nil
        samples = []
    }

    public mutating func add(_ metrics: PostureMetrics, at time: TimeInterval) -> PostureMetrics? {
        guard let startedAt else { return nil }
        samples.append(metrics)
        guard time - startedAt >= duration, samples.count >= minimumSamples else { return nil }
        let baseline = Self.median(of: samples)
        cancel()
        return baseline
    }

    private static func median(of samples: [PostureMetrics]) -> PostureMetrics {
        PostureMetrics(
            shoulderTilt: samples.map(\.shoulderTilt).median() ?? 0,
            shoulderWidth: samples.map(\.shoulderWidth).median() ?? 0,
            headHeight: samples.compactMap(\.headHeight).median(),
            headTilt: samples.compactMap(\.headTilt).median(),
            headScale: samples.compactMap(\.headScale).median(),
            earLift: samples.compactMap(\.earLift).median()
        )
    }
}
