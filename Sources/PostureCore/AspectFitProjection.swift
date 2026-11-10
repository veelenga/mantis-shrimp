import CoreGraphics

public struct AspectFitProjection: Equatable {
    public let videoRect: CGRect
    public let mirrored: Bool

    public init(frameSize: CGSize, bounds: CGRect, mirrored: Bool) {
        self.mirrored = mirrored
        guard frameSize.width > 0, frameSize.height > 0 else {
            videoRect = bounds
            return
        }
        let scale = min(bounds.width / frameSize.width, bounds.height / frameSize.height)
        let size = CGSize(width: frameSize.width * scale, height: frameSize.height * scale)
        videoRect = CGRect(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2, width: size.width, height: size.height)
    }

    public func point(_ normalized: CGPoint) -> CGPoint {
        let x = mirrored ? 1 - normalized.x : normalized.x
        return CGPoint(x: videoRect.minX + x * videoRect.width, y: videoRect.minY + normalized.y * videoRect.height)
    }
}
