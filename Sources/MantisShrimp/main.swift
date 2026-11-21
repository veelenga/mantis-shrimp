import AppKit
import PostureCore

let instanceLock: InstanceLock?
do {
    instanceLock = try InstanceLock.acquire(at: InstanceLock.defaultURL)
} catch InstanceLockError.heldByAnotherProcess {
    exit(EXIT_SUCCESS)
} catch {
    instanceLock = nil
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
