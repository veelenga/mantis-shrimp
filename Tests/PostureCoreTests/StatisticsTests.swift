import Testing
@testable import PostureCore

struct StatisticsTests {
    @Test func medianOfOddCountIsMiddleValue() {
        #expect([3.0, 1.0, 2.0].median() == 2.0)
    }

    @Test func medianOfEvenCountAveragesMiddleValues() {
        #expect([4.0, 1.0, 2.0, 3.0].median() == 2.5)
    }

    @Test func medianOfEmptyCollectionIsNil() {
        #expect([Double]().median() == nil)
    }
}
