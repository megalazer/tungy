import XCTest
@testable import Tungy

final class DailyGateTests: XCTestCase {
    private let gate = DailyGate()

    func testDayKeyRollsOverAtFourAM() throws {
        let calendar = utcCalendar
        let beforeReset = try date("2026-06-27T03:59:00Z")
        let atReset = try date("2026-06-27T04:00:00Z")

        XCTAssertEqual(gate.dayKey(for: beforeReset, resetHour: 4, calendar: calendar), "2026-06-26")
        XCTAssertEqual(gate.dayKey(for: atReset, resetHour: 4, calendar: calendar), "2026-06-27")
    }

    func testLockedAndUnlockedState() throws {
        let goal = DailyGoal(requiredCards: 2, activeDeckIDs: [], resetHour: 4)
        let locked = DailyProgress(dayKey: "2026-06-27", completedCards: 1, unlockedAt: nil)
        let unlockedAt = try date("2026-06-27T10:00:00Z")
        let unlocked = DailyProgress(dayKey: "2026-06-27", completedCards: 2, unlockedAt: unlockedAt)

        XCTAssertFalse(gate.isUnlocked(progress: locked, goal: goal))
        XCTAssertTrue(gate.isUnlocked(progress: unlocked, goal: goal))
    }

    func testRepeatedReviewsCountTowardQuota() throws {
        let calendar = utcCalendar
        let goal = DailyGoal(requiredCards: 2, activeDeckIDs: [], resetHour: 4)
        let now = try date("2026-06-27T12:00:00Z")
        var progress = DailyProgress(dayKey: "2026-06-27", completedCards: 0, unlockedAt: nil)

        let firstReviewUnlocked = gate.recordCompletedCard(progress: &progress, goal: goal, at: now, calendar: calendar)
        let secondReviewUnlocked = gate.recordCompletedCard(progress: &progress, goal: goal, at: now.addingTimeInterval(60), calendar: calendar)

        XCTAssertFalse(firstReviewUnlocked)
        XCTAssertTrue(secondReviewUnlocked)
        XCTAssertEqual(progress.completedCards, 2)
        XCTAssertEqual(progress.unlockedAt, now.addingTimeInterval(60))
        XCTAssertTrue(gate.isUnlocked(progress: progress, goal: goal))
    }

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(_ value: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: value) else {
            XCTFail("Invalid date: \(value)")
            throw DateError.invalid
        }
        return date
    }

    private enum DateError: Error {
        case invalid
    }
}
