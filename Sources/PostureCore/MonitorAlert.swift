public enum MonitorAlert: Equatable {
    case posture(Set<PostureIssue>)
    case sittingTooLong(minutes: Int)
}
