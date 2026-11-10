import Foundation

public struct MonitorSettings: Codable, Equatable {
    public static let defaultSensitivity = Sensitivity.medium
    public static let defaultAlertDelay = AlertDelay.oneMinute
    public static let defaultCameraFraming = CameraFraming.portrait

    public var sensitivity: Sensitivity
    public var alertDelay: AlertDelay
    public var cameraFraming: CameraFraming
    public var baselines: [CameraFraming: PostureMetrics]

    public init(
        sensitivity: Sensitivity = defaultSensitivity,
        alertDelay: AlertDelay = defaultAlertDelay,
        baseline: PostureMetrics? = nil,
        cameraFraming: CameraFraming = defaultCameraFraming
    ) {
        self.sensitivity = sensitivity
        self.alertDelay = alertDelay
        self.cameraFraming = cameraFraming
        baselines = [:]
        baselines[cameraFraming] = baseline
    }

    private enum CodingKeys: String, CodingKey {
        case sensitivity
        case alertDelay
        case cameraFraming
        case baselines
        case legacyBaseline = "baseline"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sensitivity = try container.decode(Sensitivity.self, forKey: .sensitivity)
        alertDelay = try container.decodeIfPresent(AlertDelay.self, forKey: .alertDelay) ?? Self.defaultAlertDelay
        cameraFraming = try container.decodeIfPresent(CameraFraming.self, forKey: .cameraFraming) ?? Self.defaultCameraFraming
        baselines = try container.decodeIfPresent([CameraFraming: PostureMetrics].self, forKey: .baselines) ?? [:]
        try mergeLegacyBaseline(from: container)
    }

    private mutating func mergeLegacyBaseline(from container: KeyedDecodingContainer<CodingKeys>) throws {
        guard let legacy = try container.decodeIfPresent(PostureMetrics.self, forKey: .legacyBaseline) else { return }
        baselines[cameraFraming] = legacy
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sensitivity, forKey: .sensitivity)
        try container.encode(alertDelay, forKey: .alertDelay)
        try container.encode(cameraFraming, forKey: .cameraFraming)
        try container.encode(baselines, forKey: .baselines)
    }

    public var baseline: PostureMetrics? {
        get { baselines[cameraFraming] }
        set { baselines[cameraFraming] = newValue }
    }

    public var isCalibrated: Bool {
        baseline != nil
    }
}
