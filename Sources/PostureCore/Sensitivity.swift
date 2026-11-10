public enum Sensitivity: String, CaseIterable, Codable {
    case low
    case medium
    case high

    public var thresholds: PostureThresholds {
        PostureThresholds.standard.scaled(by: toleranceFactor)
    }

    private static let lowToleranceFactor = 1.5
    private static let mediumToleranceFactor = 1.0
    private static let highToleranceFactor = 0.7

    private var toleranceFactor: Double {
        switch self {
        case .low: Self.lowToleranceFactor
        case .medium: Self.mediumToleranceFactor
        case .high: Self.highToleranceFactor
        }
    }
}
