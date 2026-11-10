import PostureCore

enum StatusText {
    static func line(for snapshot: MonitorSnapshot) -> String {
        var parts = [phrase(for: snapshot.phase)]
        if snapshot.sittingMinutes > 0 {
            parts.append("sitting \(snapshot.sittingMinutes) min")
        }
        if !snapshot.isCalibrated {
            parts.append("not calibrated")
        }
        return parts.joined(separator: " · ")
    }

    private static func phrase(for phase: MonitorPhase) -> String {
        switch phase {
        case .paused: "Paused"
        case .cameraUnavailable: "Camera unavailable"
        case .personNotVisible: "Shoulders not in view"
        case .calibrating: "Calibrating, sit well…"
        case .posture(_, let instant): instant.isEmpty ? "Good posture" : instant.joinedTitles
        }
    }
}
