@preconcurrency import AVFoundation
import PostureCore

enum CameraFormatSelector {
    private static let aspectTolerance = 0.05
    private static let fourByThree = 4.0 / 3.0

    static func bestFormat(for framing: CameraFraming, among formats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        switch framing {
        case .portrait: portraitFormat(among: formats) ?? landscapeFallback(among: formats)
        case .landscape: formats.filter(isLandscapeFourByThree).min(by: byHeight)
        }
    }

    static func isFourByThree(_ size: CMVideoDimensions) -> Bool {
        abs(Double(size.width) / Double(size.height) - fourByThree) < aspectTolerance
    }

    static func isThreeByFour(_ size: CMVideoDimensions) -> Bool {
        abs(Double(size.height) / Double(size.width) - fourByThree) < aspectTolerance
    }

    private static func portraitFormat(among formats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        let portrait = formats.filter { $0.formatDescription.dimensions.height > $0.formatDescription.dimensions.width }
        return portrait.filter { isThreeByFour($0.formatDescription.dimensions) }.max(by: byHeight)
            ?? portrait.max(by: byHeight)
    }

    private static func landscapeFallback(among formats: [AVCaptureDevice.Format]) -> AVCaptureDevice.Format? {
        formats.filter(isLandscapeFourByThree).max(by: byHeight)
    }

    private static func isLandscapeFourByThree(_ format: AVCaptureDevice.Format) -> Bool {
        isFourByThree(format.formatDescription.dimensions)
    }

    private static func byHeight(_ first: AVCaptureDevice.Format, _ second: AVCaptureDevice.Format) -> Bool {
        first.formatDescription.dimensions.height < second.formatDescription.dimensions.height
    }
}
