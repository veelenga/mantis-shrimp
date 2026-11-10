import Foundation
import Testing
@testable import PostureCore

struct MonitorSettingsTests {
    private let metrics = PostureMetrics(shoulderTilt: 0.01, shoulderWidth: 0.4)

    @Test func keepsOneBaselinePerCameraView() {
        var settings = MonitorSettings(cameraFraming: .portrait)
        settings.baseline = metrics
        settings.cameraFraming = .landscape
        #expect(settings.baseline == nil)
        settings.cameraFraming = .portrait
        #expect(settings.baseline == metrics)
    }

    @Test func roundTripsThroughJSON() throws {
        var settings = MonitorSettings(sensitivity: .high, alertDelay: .fiveMinutes, cameraFraming: .landscape)
        settings.baseline = metrics
        let data = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(MonitorSettings.self, from: data)
        #expect(decoded == settings)
    }

    @Test func decodesLegacySingleBaseline() throws {
        let legacy = Data(#"{"sensitivity":"low","baseline":{"shoulderTilt":0.01,"shoulderWidth":0.4}}"#.utf8)
        let decoded = try JSONDecoder().decode(MonitorSettings.self, from: legacy)
        #expect(decoded.cameraFraming == .portrait)
        #expect(decoded.baseline == metrics)
        #expect(decoded.sensitivity == .low)
        #expect(decoded.alertDelay == .oneMinute)
    }
}
