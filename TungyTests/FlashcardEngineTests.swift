import XCTest
@testable import Tungy

final class FlashcardEngineTests: XCTestCase {
    private let engine = FlashcardEngine()

    func testDailyPrioritizesNeverReviewedThenOldestThenWeakness() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let old = now.addingTimeInterval(-4 * 86_400)
        let newer = now.addingTimeInterval(-86_400)
        let deck = Deck(title: "Daily", cards: [
            card("reviewed-new", lastReviewedAt: newer, weaknessScore: 0.9),
            card("never-low", lastReviewedAt: nil, weaknessScore: 0.1),
            card("reviewed-old", lastReviewedAt: old, weaknessScore: 0.2),
            card("never-high", lastReviewedAt: nil, weaknessScore: 0.9)
        ])

        let due = engine.dueCards(in: deck, limit: 4, mode: .daily)

        XCTAssertEqual(due.map(\.front), ["never-high", "never-low", "reviewed-old", "reviewed-new"])
    }

    func testWeakSpotsPrioritizesWeaknessIncorrectThenOldest() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let old = now.addingTimeInterval(-4 * 86_400)
        let newer = now.addingTimeInterval(-86_400)
        let deck = Deck(title: "Weak", cards: [
            card("low", incorrect: 9, lastReviewedAt: old, weaknessScore: 0.2),
            card("high-fewer-misses", incorrect: 1, lastReviewedAt: old, weaknessScore: 0.8),
            card("high-more-misses", incorrect: 3, lastReviewedAt: newer, weaknessScore: 0.8),
            card("high-more-misses-oldest", incorrect: 3, lastReviewedAt: old, weaknessScore: 0.8)
        ])

        let due = engine.dueCards(in: deck, limit: 4, mode: .weakSpots)

        XCTAssertEqual(due.map(\.front), ["high-more-misses-oldest", "high-more-misses", "high-fewer-misses", "low"])
    }

    func testCramPreservesDeckOrder() {
        let deck = Deck(title: "Cram", cards: [
            card("first", weaknessScore: 0.9),
            card("second", weaknessScore: 0.1),
            card("third", weaknessScore: 0.7)
        ])

        let due = engine.dueCards(in: deck, limit: 2, mode: .cram)

        XCTAssertEqual(due.map(\.front), ["first", "second"])
    }

    func testRecordAgainUpdatesStatsExactly() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var deck = Deck(title: "Grades", cards: [card("again", weaknessScore: 0.80)])
        let cardID = deck.cards[0].id

        engine.record(.again, for: cardID, in: &deck, at: now)

        XCTAssertEqual(deck.cards[0].stats.attempts, 1)
        XCTAssertEqual(deck.cards[0].stats.correct, 0)
        XCTAssertEqual(deck.cards[0].stats.incorrect, 1)
        XCTAssertEqual(deck.cards[0].stats.weaknessScore, 1.0, accuracy: 0.0001)
        XCTAssertEqual(deck.cards[0].stats.lastReviewedAt, now)
    }

    func testRecordHardUpdatesStatsExactly() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var deck = Deck(title: "Grades", cards: [card("hard", weaknessScore: 0.20)])
        let cardID = deck.cards[0].id

        engine.record(.hard, for: cardID, in: &deck, at: now)

        XCTAssertEqual(deck.cards[0].stats.attempts, 1)
        XCTAssertEqual(deck.cards[0].stats.correct, 0)
        XCTAssertEqual(deck.cards[0].stats.incorrect, 1)
        XCTAssertEqual(deck.cards[0].stats.weaknessScore, 0.30, accuracy: 0.0001)
        XCTAssertEqual(deck.cards[0].stats.lastReviewedAt, now)
    }

    func testRecordGoodUpdatesStatsExactly() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var deck = Deck(title: "Grades", cards: [card("good", weaknessScore: 0.10)])
        let cardID = deck.cards[0].id

        engine.record(.good, for: cardID, in: &deck, at: now)

        XCTAssertEqual(deck.cards[0].stats.attempts, 1)
        XCTAssertEqual(deck.cards[0].stats.correct, 1)
        XCTAssertEqual(deck.cards[0].stats.incorrect, 0)
        XCTAssertEqual(deck.cards[0].stats.weaknessScore, 0.0, accuracy: 0.0001)
        XCTAssertEqual(deck.cards[0].stats.lastReviewedAt, now)
    }

    func testSubjectSummariesGroupBySubjectAndSortTags() {
        let pythonOne = Deck(title: "Python Basics", subject: "Python", cards: [
            card("functions", tags: ["syntax"], weaknessScore: 0.8),
            card("loops", tags: ["syntax", "loops"], weaknessScore: 0.6),
            card("comments", tags: ["basics"], weaknessScore: 0.2)
        ])
        let pythonTwo = Deck(title: "Python Advanced", subject: "Python", cards: [
            card("dicts", tags: ["data"], weaknessScore: 0.7),
            card("sets", tags: ["data"], weaknessScore: 0.5),
            card("imports", tags: ["modules"], weaknessScore: 0.5)
        ])
        let algebra = Deck(title: "Algebra", subject: "Math", cards: [
            card("linear", tags: ["equations"], weaknessScore: 0.4)
        ])

        let summaries = engine.subjectSummaries(decks: [pythonOne, pythonTwo, algebra])

        XCTAssertEqual(summaries.map(\.subject), ["Math", "Python"])
        XCTAssertEqual(summaries[0].totalCards, 1)
        XCTAssertEqual(summaries[0].averageWeakness, 0.4, accuracy: 0.0001)
        XCTAssertEqual(summaries[0].weakestTags, [])
        XCTAssertEqual(summaries[1].totalCards, 6)
        XCTAssertEqual(summaries[1].averageWeakness, 0.55, accuracy: 0.0001)
        XCTAssertEqual(summaries[1].weakestTags, ["data", "syntax", "loops"])
    }


    private func card(_ front: String, incorrect: Int = 0, tags: [String] = [], lastReviewedAt: Date? = nil, weaknessScore: Double = 0.0) -> Flashcard {
        Flashcard(
            id: UUID(),
            front: front,
            back: "Back of \(front)",
            tags: tags,
            stats: CardStats(attempts: incorrect, correct: 0, incorrect: incorrect, lastReviewedAt: lastReviewedAt, weaknessScore: weaknessScore)
        )
    }
}

private extension Deck {
    init(title: String, subject: String? = nil, cards: [Flashcard]) {
        self.init(id: UUID(), title: title, subject: subject ?? title, cards: cards)
    }
}
