import CoreGraphics

public struct PaddedFrameProjection: Equatable {
    public let scale: CGFloat
    public let topInset: CGFloat

    public init(scale: CGFloat, topInset: CGFloat) {
        self.scale = scale
        self.topInset = topInset
    }

    public var horizontalInset: CGFloat { (1 - scale) / 2 }
    public var bottomInset: CGFloat { 1 - topInset - scale }

    public func frameRect(in canvas: CGSize) -> CGRect {
        CGRect(
            x: horizontalInset * canvas.width,
            y: bottomInset * canvas.height,
            width: scale * canvas.width,
            height: scale * canvas.height
        )
    }

    public func sourcePoint(fromPadded point: CGPoint) -> CGPoint {
        CGPoint(x: (point.x - horizontalInset) / scale, y: (point.y - bottomInset) / scale)
    }
}
