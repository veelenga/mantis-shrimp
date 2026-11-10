import Testing
@testable import PostureCore

struct CameraModeTests {
    @Test func previewWinsOverEverything() {
        #expect(CameraMode.resolve(isPreviewing: true, isLowPower: true, absentFor: 600) == .preview)
    }

    @Test func presentUserOnFullPowerIsActive() {
        #expect(CameraMode.resolve(isPreviewing: false, isLowPower: false, absentFor: nil) == .active)
        #expect(CameraMode.resolve(isPreviewing: false, isLowPower: false, absentFor: 59) == .active)
    }

    @Test func longAbsenceIsIdle() {
        let absence = MonitorTiming.Camera.idleAfter
        #expect(CameraMode.resolve(isPreviewing: false, isLowPower: false, absentFor: absence) == .idle)
    }

    @Test func lowPowerIsIdle() {
        #expect(CameraMode.resolve(isPreviewing: false, isLowPower: true, absentFor: nil) == .idle)
    }

    @Test func profilesSlowDownWhenIdle() {
        #expect(CameraMode.idle.profile.frameRate < CameraMode.active.profile.frameRate)
        #expect(CameraMode.idle.profile.analysisInterval > CameraMode.active.profile.analysisInterval)
    }
}
