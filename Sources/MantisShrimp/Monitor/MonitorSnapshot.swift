import PostureCore

enum MonitorPhase: Equatable {
    case paused
    case cameraUnavailable
    case personNotVisible
    case calibrating
    case posture(sustained: Set<PostureIssue>, instant: Set<PostureIssue>)
}

struct MonitorSnapshot: Equatable {
    var phase: MonitorPhase
    var isCalibrated: Bool
    var alert: MonitorAlert? = nil
    var sittingMinutes = 0

    var issues: Set<PostureIssue> {
        if case .posture(let sustained, _) = phase { return sustained }
        return []
    }

    var instantIssues: Set<PostureIssue> {
        if case .posture(_, let instant) = phase { return instant }
        return []
    }

    var hasInstantIssues: Bool {
        !instantIssues.isEmpty
    }
}
