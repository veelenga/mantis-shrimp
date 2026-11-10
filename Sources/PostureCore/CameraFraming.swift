public enum CameraFraming: String, CaseIterable, Codable {
    case portrait
    case landscape

    public var title: String {
        switch self {
        case .portrait: "Portrait (sees furthest down)"
        case .landscape: "Landscape (wide)"
        }
    }
}
