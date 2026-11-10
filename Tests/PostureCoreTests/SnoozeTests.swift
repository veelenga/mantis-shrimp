import Testing
@testable import PostureCore

struct SnoozeTests {
    @Test func isInactiveUntilStarted() {
        #expect(!Snooze().isActive(at: 0))
    }

    @Test func staysActiveForTheDuration() {
        var snooze = Snooze()
        snooze.start(at: 10, duration: 5)
        #expect(snooze.isActive(at: 14.9))
        #expect(!snooze.isActive(at: 15))
    }
}
