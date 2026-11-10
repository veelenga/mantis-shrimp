import CoreGraphics

public enum ShrimpAppIcon {
    private static let squareInset: CGFloat = 0.1
    private static let cornerRatio: CGFloat = 0.225
    private static let shrimpInset: CGFloat = 0.13
    private static let topColor = CGColor(red: 0.10, green: 0.16, blue: 0.30, alpha: 1)
    private static let bottomColor = CGColor(red: 0.04, green: 0.06, blue: 0.14, alpha: 1)
    private static let palette = ShrimpShape.Palette(
        body: CGColor(red: 0.24, green: 0.72, blue: 0.50, alpha: 1),
        shade: CGColor(red: 0.12, green: 0.50, blue: 0.36, alpha: 1),
        accent: CGColor(red: 1.0, green: 0.45, blue: 0.30, alpha: 1),
        eye: CGColor(red: 0.06, green: 0.09, blue: 0.14, alpha: 1),
        eyeRing: CGColor(red: 0.55, green: 0.93, blue: 0.85, alpha: 1)
    )

    private struct Shadow {
        let offsetRatio: CGFloat
        let blurRatio: CGFloat
        let alpha: CGFloat

        func apply(to context: CGContext, side: CGFloat) {
            context.setShadow(
                offset: CGSize(width: 0, height: -side * offsetRatio),
                blur: side * blurRatio,
                color: CGColor(gray: 0, alpha: alpha)
            )
        }
    }

    private static let plateShadow = Shadow(offsetRatio: 0.012, blurRatio: 0.03, alpha: 0.35)
    private static let shrimpShadow = Shadow(offsetRatio: 0.015, blurRatio: 0.035, alpha: 0.4)
    private static let colorSpace = CGColorSpaceCreateDeviceRGB()

    public static func render(size: Int) -> CGImage? {
        guard let context = makeContext(size: size) else { return nil }
        let side = CGFloat(size)
        let plate = plateShape(side: side)
        drawPlateShadow(in: context, plate: plate, side: side)
        drawBackground(in: context, plate: plate, side: side)
        drawShrimp(in: context, side: side)
        return context.makeImage()
    }

    private static func makeContext(size: Int) -> CGContext? {
        CGContext(
            data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
            space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    private static func plateSquare(side: CGFloat) -> CGRect {
        CGRect(x: 0, y: 0, width: side, height: side).insetBy(dx: side * squareInset, dy: side * squareInset)
    }

    private static func plateShape(side: CGFloat) -> CGPath {
        let square = plateSquare(side: side)
        return CGPath(
            roundedRect: square,
            cornerWidth: square.width * cornerRatio,
            cornerHeight: square.width * cornerRatio,
            transform: nil
        )
    }

    private static func drawPlateShadow(in context: CGContext, plate: CGPath, side: CGFloat) {
        context.saveGState()
        plateShadow.apply(to: context, side: side)
        context.addPath(plate)
        context.setFillColor(bottomColor)
        context.fillPath()
        context.restoreGState()
    }

    private static func drawBackground(in context: CGContext, plate: CGPath, side: CGFloat) {
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: [topColor, bottomColor] as CFArray, locations: [0, 1]) else { return }
        context.saveGState()
        context.addPath(plate)
        context.clip()
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: side), end: .zero, options: [])
        context.restoreGState()
    }

    private static func drawShrimp(in context: CGContext, side: CGFloat) {
        let square = plateSquare(side: side)
        let shrimp = ShrimpShape(pose: .portrait, in: square.insetBy(dx: square.width * shrimpInset, dy: square.height * shrimpInset))
        context.saveGState()
        context.addPath(plateShape(side: side))
        context.clip()
        shrimpShadow.apply(to: context, side: side)
        shrimp.drawDetailed(in: context, palette: palette)
        context.restoreGState()
    }
}
