import CoreGraphics

struct Bounds {
    private var minX = CGFloat.infinity
    private var minY = CGFloat.infinity
    private var maxX = -CGFloat.infinity
    private var maxY = -CGFloat.infinity

    private var width: CGFloat { maxX - minX }
    private var height: CGFloat { maxY - minY }
    private var midX: CGFloat { (minX + maxX) / 2 }
    private var midY: CGFloat { (minY + maxY) / 2 }

    mutating func include(_ point: CGPoint, _ radius: CGFloat) {
        minX = min(minX, point.x - radius)
        maxX = max(maxX, point.x + radius)
        minY = min(minY, point.y - radius)
        maxY = max(maxY, point.y + radius)
    }

    func scale(fitting rect: CGRect) -> CGFloat {
        min(rect.width / width, rect.height / height)
    }

    func fitTransform(into rect: CGRect) -> CGAffineTransform {
        let scale = scale(fitting: rect)
        return CGAffineTransform(translationX: rect.midX - midX * scale, y: rect.midY - midY * scale)
            .scaledBy(x: scale, y: scale)
    }
}

extension CGRect {
    init(center: CGPoint, radius: CGFloat) {
        self.init(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
    }
}

extension CGPoint {
    func moved(along direction: CGPoint, by distance: CGFloat) -> CGPoint {
        CGPoint(x: x + direction.x * distance, y: y + direction.y * distance)
    }

    func rotated(by angle: CGFloat) -> CGPoint {
        CGPoint(x: x * cos(angle) - y * sin(angle), y: x * sin(angle) + y * cos(angle))
    }
}
