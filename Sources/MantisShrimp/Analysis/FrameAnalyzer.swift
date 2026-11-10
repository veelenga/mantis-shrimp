import CoreVideo
import Foundation
import os
import PostureCore

struct AnalyzedFrame {
    let detection: FrameDetection?
    let frameSize: CGSize
}

final class FrameAnalyzer: @unchecked Sendable {
    private struct Throttle {
        var interval: TimeInterval
        var lastAnalysisAt: TimeInterval = 0
    }

    private let detector = LandmarksDetector()
    private let throttle: OSAllocatedUnfairLock<Throttle>

    init(interval: TimeInterval) {
        throttle = OSAllocatedUnfairLock(initialState: Throttle(interval: interval))
    }

    var interval: TimeInterval {
        get { throttle.withLock { $0.interval } }
        set { throttle.withLock { $0.interval = newValue } }
    }

    func analyze(_ buffer: CVPixelBuffer) -> AnalyzedFrame? {
        guard claimSlot(at: ProcessInfo.processInfo.systemUptime) else { return nil }
        let frameSize = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
        let detection = detector.detect(in: buffer).flatMap { landmarks in
            PostureMetrics(landmarks: landmarks).map { FrameDetection(landmarks: landmarks, metrics: $0) }
        }
        return AnalyzedFrame(detection: detection, frameSize: frameSize)
    }

    private func claimSlot(at time: TimeInterval) -> Bool {
        throttle.withLock { throttle in
            guard time - throttle.lastAnalysisAt >= throttle.interval else { return false }
            throttle.lastAnalysisAt = time
            return true
        }
    }
}
