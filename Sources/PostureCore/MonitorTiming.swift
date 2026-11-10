import Foundation

public enum MonitorTiming {
    public enum Detection {
        public static let onsetDelay: TimeInterval = 10
        public static let releaseDelay: TimeInterval = 2
        public static let hold: TimeInterval = 3
    }

    public enum Alert {
        public static let snooze: TimeInterval = 5 * 60
    }

    public enum Sitting {
        public static let limit: TimeInterval = 50 * 60
        public static let breakDuration: TimeInterval = 2 * 60
        public static let snooze: TimeInterval = 10 * 60
    }

    public enum Camera {
        public static let calibrationDuration: TimeInterval = 5
        public static let resetAfterAbsence: TimeInterval = 30
        public static let idleAfter: TimeInterval = 60
    }
}
