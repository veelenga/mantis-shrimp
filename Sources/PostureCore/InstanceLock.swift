import Foundation

public enum InstanceLockError: Error, Equatable {
    case heldByAnotherProcess
    case unavailable(errno: Int32)
}

public final class InstanceLock {
    private static let fileName = "instance.lock"
    private static let filePermissions: mode_t = 0o600

    private let descriptor: Int32

    private init(descriptor: Int32) {
        self.descriptor = descriptor
    }

    deinit {
        close(descriptor)
    }

    public static var defaultURL: URL {
        FileHistoryStore.rootDirectory.appendingPathComponent(fileName)
    }

    public static func acquire(at url: URL) throws -> InstanceLock {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let descriptor = open(url.path, O_CREAT | O_RDWR | O_CLOEXEC, filePermissions)
        guard descriptor >= 0 else {
            throw InstanceLockError.unavailable(errno: errno)
        }
        guard flock(descriptor, LOCK_EX | LOCK_NB) == 0 else {
            let failure = errno
            close(descriptor)
            throw failure == EWOULDBLOCK ? InstanceLockError.heldByAnotherProcess : .unavailable(errno: failure)
        }
        return InstanceLock(descriptor: descriptor)
    }
}
