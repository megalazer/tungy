import XCTest
@testable import Tungy

final class TungyTests: XCTestCase {
    func testAppName() {
        XCTAssertEqual("Tungy", "Tungy")
    }

    func testAttentionProfilePrefersMorningScroller() {
        let profile = makeAttentionProfile(
            goal: .reduceScrolling,
            impact: .loseFocus,
            lossTime: .mornings,
            dailyHours: 4
        )

        XCTAssertEqual(profile.title, "The Morning Scroller")
    }

    func testAttentionProfileUsesDeepFeedDiverForHighDailyHours() {
        let profile = makeAttentionProfile(
            goal: .improveFocus,
            impact: .wasteTime,
            lossTime: .duringDay,
            dailyHours: 6
        )

        XCTAssertEqual(profile.title, "The Deep Feed Diver")
    }

    func testAttentionProfileBuilderForGetSmarterGoal() {
        let profile = makeAttentionProfile(
            goal: .getSmarter,
            impact: .loseFocus,
            lossTime: .notSure,
            dailyHours: 3
        )

        XCTAssertEqual(profile.title, "The Builder")
    }
}
