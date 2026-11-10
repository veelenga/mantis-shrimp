import CoreGraphics

extension CGPoint {
    func distance(to other: CGPoint) -> Double {
        hypot(x - other.x, y - other.y)
    }
}
