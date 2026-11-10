import AppKit
import ShrimpArt

extension NSImage {
    static func shrimpGlyph(pose: ShrimpShape.Pose, size: NSSize, color: NSColor, inset: CGFloat = 0) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            let shape = ShrimpShape(pose: pose, in: rect.insetBy(dx: inset, dy: inset))
            shape.drawGlyph(in: context, color: color.cgColor)
            return true
        }
    }
}
