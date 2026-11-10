import Testing
@testable import PostureCore

struct LastValueHoldTests {
    @Test func keepsLastValueDuringShortDropouts() {
        var hold = LastValueHold<Int>(duration: 3)
        #expect(hold.update(1, at: 0) == 1)
        #expect(hold.update(nil, at: 1) == 1)
        #expect(hold.update(nil, at: 2.9) == 1)
        #expect(hold.update(2, at: 3) == 2)
    }

    @Test func givesUpAfterTheHoldDuration() {
        var hold = LastValueHold<Int>(duration: 3)
        _ = hold.update(1, at: 0)
        #expect(hold.update(nil, at: 3) == nil)
        #expect(hold.update(nil, at: 3.5) == nil)
    }

    @Test func startsEmpty() {
        var hold = LastValueHold<Int>(duration: 3)
        #expect(hold.update(nil, at: 0) == nil)
    }
}
