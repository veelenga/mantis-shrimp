import Foundation
import ImageIO
import ShrimpArt
import UniformTypeIdentifiers

private let pointSizes = [16, 32, 128, 256, 512]
private let scales = [1, 2]
private let usageExitCode: Int32 = 1
private let renderFailureExitCode: Int32 = 2

private func fileName(points: Int, scale: Int) -> String {
    let suffix = scale == 2 ? "@2x" : ""
    return "icon_\(points)x\(points)\(suffix).png"
}

private func fail(_ message: String, code: Int32) -> Never {
    FileHandle.standardError.write(Data("\(message)\n".utf8))
    exit(code)
}

private func write(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw CocoaError(.fileWriteUnknown)
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else { throw CocoaError(.fileWriteUnknown) }
}

private func writeIconset(to output: URL) throws {
    try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
    for points in pointSizes {
        for scale in scales {
            let pixels = points * scale
            guard let image = ShrimpAppIcon.render(size: pixels) else {
                fail("ShrimpIconTool: failed to render \(pixels)x\(pixels) icon", code: renderFailureExitCode)
            }
            try write(image, to: output.appendingPathComponent(fileName(points: points, scale: scale)))
        }
    }
}

guard CommandLine.arguments.count == 2 else {
    fail("usage: ShrimpIconTool <output.iconset>", code: usageExitCode)
}

try writeIconset(to: URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true))
