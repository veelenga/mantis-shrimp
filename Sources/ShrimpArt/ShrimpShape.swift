import CoreGraphics

public struct ShrimpShape {
    public enum Pose {
        case tall
        case curled
        case portrait

        var spanDegrees: CGFloat {
            switch self {
            case .tall: 120
            case .curled: 240
            case .portrait: 130
            }
        }

        var startDegrees: CGFloat {
            switch self {
            case .tall: 50
            case .curled: 120
            case .portrait: 60
            }
        }
    }

    public struct Palette {
        public let body: CGColor
        public let shade: CGColor
        public let accent: CGColor
        public let eye: CGColor
        public let eyeRing: CGColor

        public init(body: CGColor, shade: CGColor, accent: CGColor, eye: CGColor, eyeRing: CGColor) {
            self.body = body
            self.shade = shade
            self.accent = accent
            self.eye = eye
            self.eyeRing = eyeRing
        }
    }

    private enum Body {
        static let steps = 48
        static let radius: CGFloat = 0.30
        static let taper: CGFloat = 0.45
    }

    private enum Head {
        static let radius = Body.radius
        static let radiusScale: CGFloat = 1.05
        static let centerOffset: CGFloat = 0.5
        static let shieldSetback: CGFloat = 0.1
        static let shieldReach: CGFloat = 0.9
    }

    private enum Eye {
        static let radius: CGFloat = 0.13
        static let pupilInset: CGFloat = 0.22
        static let sides: [CGFloat] = [1.0, -0.25]
        static let stalkBaseForward: CGFloat = 0.7
        static let stalkBaseOutward: CGFloat = 0.45
        static let stalkTipForward: CGFloat = 1.55
        static let stalkTipOutward: CGFloat = 1.05
        static let centerForward: CGFloat = 0.6
    }

    private enum Antenna {
        static let shapes: [(lift: CGFloat, length: CGFloat)] = [(0.35, 0.95), (0.15, 0.75)]
        static let baseForward: CGFloat = 0.9
        static let baseOutward: CGFloat = 0.6
        static let endOutward: CGFloat = 0.25
        static let endForward: CGFloat = 0.3
        static let controlOutward: CGFloat = 0.5
        static let controlForward: CGFloat = 0.6
        static let boundsRadius: CGFloat = 0.05
    }

    private enum ClubArm {
        static let shapes: [(drop: CGFloat, reach: CGFloat)] = [(0.55, 0.62), (0.95, 0.48)]
        static let clubRadius: CGFloat = 0.12
        static let shoulderBack: CGFloat = 0.2
        static let elbowBack: CGFloat = 0.12
        static let elbowDrop: CGFloat = 0.45
        static let knuckleExtra: CGFloat = 0.25
        static let knuckleLift: CGFloat = 0.02
        static let elbowBoundsRadius: CGFloat = 0.1
    }

    private enum Tail {
        static let spreads: [CGFloat] = [-0.8, -0.3, 0.3, 0.8]
        static let innerSpreadLimit: CGFloat = 0.5
        static let innerLength: CGFloat = 0.5
        static let outerLength: CGFloat = 0.42
        static let halfWidth: CGFloat = 0.09
        static let tipExtension: CGFloat = 0.1
        static let boundsRadius: CGFloat = 0.12
    }

    private enum Legs {
        static let count = 7
        static let firstPosition: CGFloat = 0.2
        static let rootDepth: CGFloat = 0.6
        static let tipDepth: CGFloat = 0.2
        static let tipSlide: CGFloat = -0.1
        static let controlDepth: CGFloat = 0.1
        static let controlSlide: CGFloat = 0.03
    }

    private enum Segments {
        static let count = 8
        static let firstPosition: CGFloat = 0.16
        static let reach: CGFloat = 0.95
        static let curve: CGFloat = 0.3
    }

    private static let positionStep: CGFloat = 0.1

    private enum LineWidth {
        enum Glyph {
            static let stalks: CGFloat = 0.1
            static let clubArms: CGFloat = 0.16
            static let antennae: CGFloat = 0.08
        }

        enum Detailed {
            static let antennae: CGFloat = 0.06
            static let legs: CGFloat = 0.07
            static let clubArms: CGFloat = 0.15
            static let segments: CGFloat = 0.045
            static let stalks: CGFloat = 0.09
        }
    }

    private struct Anatomy {
        let start: CGFloat
        let span: CGFloat

        init(pose: Pose) {
            span = pose.spanDegrees * .pi / 180
            start = pose.startDegrees * .pi / 180
        }

        var forward: CGPoint { CGPoint(x: -sin(start), y: cos(start)) }
        var outward: CGPoint { point(start) }
        var headRadius: CGFloat { Head.radius * Head.radiusScale }
        var headCenter: CGPoint { point(start).moved(along: forward, by: Head.radius * Head.centerOffset) }

        func angle(at position: CGFloat) -> CGFloat { start - span * position }
        func point(_ angle: CGFloat) -> CGPoint { CGPoint(x: cos(angle), y: sin(angle)) }
        func tangent(_ angle: CGFloat) -> CGPoint { CGPoint(x: sin(angle), y: -cos(angle)) }
        func inward(_ angle: CGFloat) -> CGPoint { CGPoint(x: -cos(angle), y: -sin(angle)) }
        func thickness(_ position: CGFloat) -> CGFloat { Body.radius * (1 - Body.taper * position * position) }
    }

    private struct Parts {
        var body = CGMutablePath()
        var tail = CGMutablePath()
        var antennae = CGMutablePath()
        var legs = CGMutablePath()
        var segments = CGMutablePath()
        var stalks = CGMutablePath()
        var clubArms = CGMutablePath()
        var clubs = CGMutablePath()
        var eyes: [CGRect] = []

        func transformed(by transform: CGAffineTransform) -> Parts {
            var transform = transform
            func apply(_ path: CGMutablePath) -> CGMutablePath { path.mutableCopy(using: &transform) ?? path }
            return Parts(
                body: apply(body),
                tail: apply(tail),
                antennae: apply(antennae),
                legs: apply(legs),
                segments: apply(segments),
                stalks: apply(stalks),
                clubArms: apply(clubArms),
                clubs: apply(clubs),
                eyes: eyes.map { $0.applying(transform) }
            )
        }
    }

    private struct Builder {
        let anatomy: Anatomy
        var parts = Parts()
        var bounds = Bounds()

        init(pose: Pose) {
            anatomy = Anatomy(pose: pose)
        }

        mutating func build() {
            addBody()
            addHead()
            addEyes()
            addAntennae()
            addClubArms()
            addTail()
            addLegs()
            addSegments()
        }

        private mutating func addBody() {
            for i in 0...Body.steps {
                let position = CGFloat(i) / CGFloat(Body.steps)
                let center = anatomy.point(anatomy.angle(at: position))
                let radius = anatomy.thickness(position)
                parts.body.addEllipse(in: CGRect(center: center, radius: radius))
                bounds.include(center, radius)
            }
        }

        private mutating func addHead() {
            let center = anatomy.headCenter
            let radius = anatomy.headRadius
            let forward = anatomy.forward
            let outward = anatomy.outward
            parts.body.addEllipse(in: CGRect(center: center, radius: radius))
            bounds.include(center, radius)

            let shield = CGMutablePath()
            shield.move(to: center.moved(along: outward, by: radius).moved(along: forward, by: -Head.shieldSetback))
            shield.addLine(to: center.moved(along: outward, by: radius * Head.shieldReach).moved(along: forward, by: radius * Head.shieldReach))
            shield.addLine(to: center.moved(along: outward, by: -radius * Head.shieldReach).moved(along: forward, by: radius * Head.shieldReach))
            shield.addLine(to: center.moved(along: outward, by: -radius).moved(along: forward, by: -Head.shieldSetback))
            shield.closeSubpath()
            parts.body.addPath(shield)
        }

        private mutating func addEyes() {
            let center = anatomy.headCenter
            let radius = anatomy.headRadius
            let forward = anatomy.forward
            let outward = anatomy.outward
            for side in Eye.sides {
                let base = center.moved(along: forward, by: radius * Eye.stalkBaseForward)
                    .moved(along: outward, by: radius * Eye.stalkBaseOutward * side)
                let tip = center.moved(along: forward, by: radius * Eye.stalkTipForward)
                    .moved(along: outward, by: radius * Eye.stalkTipOutward * side)
                parts.stalks.move(to: base)
                parts.stalks.addLine(to: tip)
                let eyeCenter = tip.moved(along: forward, by: Eye.radius * Eye.centerForward)
                parts.eyes.append(CGRect(center: eyeCenter, radius: Eye.radius))
                bounds.include(eyeCenter, Eye.radius)
            }
        }

        private mutating func addAntennae() {
            let center = anatomy.headCenter
            let radius = anatomy.headRadius
            let forward = anatomy.forward
            let outward = anatomy.outward
            for (lift, length) in Antenna.shapes {
                let base = center.moved(along: forward, by: radius * Antenna.baseForward)
                    .moved(along: outward, by: radius * Antenna.baseOutward)
                let end = center.moved(along: outward, by: radius + lift + Antenna.endOutward)
                    .moved(along: forward, by: Antenna.endForward - length)
                let control = center.moved(along: outward, by: radius + lift + Antenna.controlOutward)
                    .moved(along: forward, by: radius * Antenna.controlForward)
                parts.antennae.move(to: base)
                parts.antennae.addQuadCurve(to: end, control: control)
                bounds.include(end, Antenna.boundsRadius)
            }
        }

        private mutating func addClubArms() {
            let center = anatomy.headCenter
            let radius = anatomy.headRadius
            let forward = anatomy.forward
            let outward = anatomy.outward
            for (drop, reach) in ClubArm.shapes {
                let shoulder = center.moved(along: forward, by: -radius * ClubArm.shoulderBack)
                    .moved(along: outward, by: -radius * drop)
                let elbow = shoulder.moved(along: forward, by: -ClubArm.elbowBack)
                    .moved(along: outward, by: -ClubArm.elbowDrop)
                let knuckle = elbow.moved(along: forward, by: reach + ClubArm.knuckleExtra)
                    .moved(along: outward, by: ClubArm.knuckleLift)
                parts.clubArms.move(to: shoulder)
                parts.clubArms.addLine(to: elbow)
                parts.clubArms.addLine(to: knuckle)
                parts.clubs.addEllipse(in: CGRect(center: knuckle, radius: ClubArm.clubRadius))
                bounds.include(knuckle, ClubArm.clubRadius)
                bounds.include(elbow, ClubArm.elbowBoundsRadius)
            }
        }

        private mutating func addTail() {
            let angle = anatomy.angle(at: 1)
            let root = anatomy.point(angle)
            let tailDirection = anatomy.tangent(angle)
            for spread in Tail.spreads {
                let direction = tailDirection.rotated(by: spread)
                let length = abs(spread) < Tail.innerSpreadLimit ? Tail.innerLength : Tail.outerLength
                let tip = root.moved(along: direction, by: length)
                let normal = CGPoint(x: -direction.y * Tail.halfWidth, y: direction.x * Tail.halfWidth)
                parts.tail.move(to: root)
                parts.tail.addLine(to: CGPoint(x: tip.x + normal.x, y: tip.y + normal.y))
                parts.tail.addLine(to: tip.moved(along: direction, by: Tail.tipExtension))
                parts.tail.addLine(to: CGPoint(x: tip.x - normal.x, y: tip.y - normal.y))
                parts.tail.closeSubpath()
                bounds.include(tip, Tail.boundsRadius)
            }
        }

        private mutating func addLegs() {
            for i in 0..<Legs.count {
                let position = Legs.firstPosition + CGFloat(i) * positionStep
                let angle = anatomy.angle(at: position)
                let center = anatomy.point(angle)
                let depth = anatomy.thickness(position)
                let inward = anatomy.inward(angle)
                let tangent = anatomy.tangent(angle)
                parts.legs.move(to: center.moved(along: inward, by: depth * Legs.rootDepth))
                parts.legs.addQuadCurve(
                    to: center.moved(along: inward, by: depth + Legs.tipDepth).moved(along: tangent, by: Legs.tipSlide),
                    control: center.moved(along: inward, by: depth + Legs.controlDepth).moved(along: tangent, by: Legs.controlSlide)
                )
            }
        }

        private mutating func addSegments() {
            for i in 0..<Segments.count {
                let position = Segments.firstPosition + CGFloat(i) * positionStep
                let angle = anatomy.angle(at: position)
                let center = anatomy.point(angle)
                let depth = anatomy.thickness(position)
                let inward = anatomy.inward(angle)
                parts.segments.move(to: center.moved(along: inward, by: -depth * Segments.reach))
                parts.segments.addQuadCurve(
                    to: center.moved(along: inward, by: depth * Segments.reach),
                    control: center.moved(along: anatomy.tangent(angle), by: -depth * Segments.curve)
                )
            }
        }
    }

    private let parts: Parts
    private let unit: CGFloat

    public init(pose: Pose, in rect: CGRect) {
        var builder = Builder(pose: pose)
        builder.build()
        parts = builder.parts.transformed(by: builder.bounds.fitTransform(into: rect))
        unit = builder.bounds.scale(fitting: rect)
    }

    public func drawGlyph(in context: CGContext, color: CGColor) {
        context.setLineCap(.round)
        context.setLineJoin(.round)
        fill(parts.body, color: color, in: context)
        fill(parts.tail, color: color, in: context)
        stroke(parts.stalks, color: color, width: LineWidth.Glyph.stalks, in: context)
        context.setFillColor(color)
        parts.eyes.forEach { context.fillEllipse(in: $0) }
        stroke(parts.clubArms, color: color, width: LineWidth.Glyph.clubArms, in: context)
        fill(parts.clubs, color: color, in: context)
        stroke(parts.antennae, color: color, width: LineWidth.Glyph.antennae, in: context)
    }

    public func drawDetailed(in context: CGContext, palette: Palette) {
        context.setLineCap(.round)
        context.setLineJoin(.round)
        stroke(parts.antennae, color: palette.body, width: LineWidth.Detailed.antennae, in: context)
        stroke(parts.legs, color: palette.accent, width: LineWidth.Detailed.legs, in: context)
        fill(parts.tail, color: palette.body, in: context)
        stroke(parts.clubArms, color: palette.accent, width: LineWidth.Detailed.clubArms, in: context)
        fill(parts.clubs, color: palette.accent, in: context)
        fill(parts.body, color: palette.body, in: context)
        drawSegments(in: context, color: palette.shade)
        stroke(parts.stalks, color: palette.body, width: LineWidth.Detailed.stalks, in: context)
        for eye in parts.eyes {
            context.setFillColor(palette.eyeRing)
            context.fillEllipse(in: eye)
            context.setFillColor(palette.eye)
            context.fillEllipse(in: eye.insetBy(dx: eye.width * Eye.pupilInset, dy: eye.width * Eye.pupilInset))
        }
    }

    private func drawSegments(in context: CGContext, color: CGColor) {
        context.saveGState()
        context.addPath(parts.body)
        context.clip()
        stroke(parts.segments, color: color, width: LineWidth.Detailed.segments, in: context)
        context.restoreGState()
    }

    private func stroke(_ path: CGPath, color: CGColor, width: CGFloat, in context: CGContext) {
        context.setStrokeColor(color)
        context.setLineWidth(unit * width)
        context.addPath(path)
        context.strokePath()
    }

    private func fill(_ path: CGPath, color: CGColor, in context: CGContext) {
        context.setFillColor(color)
        context.addPath(path)
        context.fillPath()
    }
}
