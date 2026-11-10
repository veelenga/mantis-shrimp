import CoreGraphics
import PostureCore

struct FrameDetection: Equatable {
    let landmarks: BodyLandmarks
    let metrics: PostureMetrics
}

struct FrameAnalysis: Equatable {
    var frameSize: CGSize
    var landmarks: BodyLandmarks?
    var deviations: PostureDeviations?
    var thresholds: PostureThresholds
    var instantIssues: Set<PostureIssue>

    static func empty(frameSize: CGSize, thresholds: PostureThresholds) -> FrameAnalysis {
        FrameAnalysis(frameSize: frameSize, landmarks: nil, deviations: nil, thresholds: thresholds, instantIssues: [])
    }
}
