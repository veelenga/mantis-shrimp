import Foundation

public struct CameraProfile: Equatable {
    public static let active = CameraProfile(frameRate: 2, analysisInterval: 0.5)
    public static let idle = CameraProfile(frameRate: 1, analysisInterval: 1.0)
    public static let preview = CameraProfile(frameRate: 15, analysisInterval: 0.2)

    public let frameRate: Int32
    public let analysisInterval: TimeInterval
}

public enum CameraMode: Equatable {
    case active
    case idle
    case preview

    public var profile: CameraProfile {
        switch self {
        case .active: .active
        case .idle: .idle
        case .preview: .preview
        }
    }

    public static func resolve(isPreviewing: Bool, isLowPower: Bool, absentFor: TimeInterval?) -> CameraMode {
        if isPreviewing { return .preview }
        let isAbsentLong = absentFor.map { $0 >= MonitorTiming.Camera.idleAfter } ?? false
        return isAbsentLong || isLowPower ? .idle : .active
    }
}
