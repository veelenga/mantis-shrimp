import CoreGraphics

public enum CameraWindowSizing {
    public static let landscapeWidth: CGFloat = 640
    public static let portraitWidth: CGFloat = 520
    public static let defaultAspectRatio: CGFloat = 3 / 4
    public static let readoutHeight: CGFloat = 116

    public static let initialContentSize = CGSize(
        width: landscapeWidth,
        height: landscapeWidth * defaultAspectRatio + readoutHeight
    )

    public static func contentSize(for frameSize: CGSize) -> CGSize {
        let width = frameSize.height > frameSize.width ? portraitWidth : landscapeWidth
        return CGSize(width: width, height: width * frameSize.height / frameSize.width + readoutHeight)
    }
}
