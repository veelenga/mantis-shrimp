import Foundation
import Testing
@testable import PostureCore

struct InstanceLockTests {
    private func makeLockURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("instance.lock")
    }

    @Test func acquiresFreeLockAndCreatesItsDirectory() throws {
        let url = makeLockURL()
        _ = try InstanceLock.acquire(at: url)
        #expect(FileManager.default.fileExists(atPath: url.path))
    }

    @Test func refusesSecondHolderWhileLockIsHeld() throws {
        let url = makeLockURL()
        let held = try InstanceLock.acquire(at: url)
        #expect(throws: InstanceLockError.heldByAnotherProcess) {
            try InstanceLock.acquire(at: url)
        }
        withExtendedLifetime(held) {}
    }

    @Test func allowsNewHolderAfterRelease() throws {
        let url = makeLockURL()
        do {
            _ = try InstanceLock.acquire(at: url)
        }
        _ = try InstanceLock.acquire(at: url)
    }

    @Test func reportsUnavailableWhenLockFileCannotBeOpened() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        #expect(throws: InstanceLockError.unavailable(errno: EISDIR)) {
            try InstanceLock.acquire(at: directory)
        }
    }
}
