import Foundation

struct FlashcardEngine {
    func dueCards(in deck: Deck, limit: Int, mode: StudyMode) -> [Flashcard] {
        let safeLimit = max(0, limit)

        switch mode {
        case .daily:
            return Array(deck.cards.sorted(by: dailySort).prefix(safeLimit))
        case .weakSpots:
            return Array(deck.cards.sorted(by: weakSpotsSort).prefix(safeLimit))
        case .cram:
            return Array(deck.cards.prefix(safeLimit))
        }
    }

    func record(_ grade: ReviewGrade, for cardID: UUID, in deck: inout Deck, at now: Date) {
        guard let index = deck.cards.firstIndex(where: { $0.id == cardID }) else { return }

        deck.cards[index].stats.attempts += 1
        deck.cards[index].stats.lastReviewedAt = now

        switch grade {
        case .again:
            deck.cards[index].stats.incorrect += 1
            deck.cards[index].stats.weaknessScore = min(1.0, deck.cards[index].stats.weaknessScore + 0.25)
        case .hard:
            deck.cards[index].stats.incorrect += 1
            deck.cards[index].stats.weaknessScore = min(1.0, deck.cards[index].stats.weaknessScore + 0.10)
        case .good:
            deck.cards[index].stats.correct += 1
            deck.cards[index].stats.weaknessScore = max(0.0, deck.cards[index].stats.weaknessScore - 0.20)
        }
    }

    func subjectSummaries(decks: [Deck]) -> [SubjectSummary] {
        let groupedCards = Dictionary(grouping: decks, by: \.subject)
            .mapValues { decks in decks.flatMap(\.cards) }

        return groupedCards.map { subject, cards in
            let totalCards = cards.count
            let averageWeakness = totalCards == 0 ? 0.0 : cards.reduce(0.0) { $0 + $1.stats.weaknessScore } / Double(totalCards)
            let weakTagCounts = cards
                .filter { $0.stats.weaknessScore >= 0.5 }
                .flatMap(\.tags)
                .reduce(into: [String: Int]()) { counts, tag in
                    counts[tag, default: 0] += 1
                }

            let weakestTags = weakTagCounts
                .sorted { lhs, rhs in
                    if lhs.value != rhs.value {
                        return lhs.value > rhs.value
                    }
                    return lhs.key < rhs.key
                }
                .prefix(3)
                .map(\.key)

            return SubjectSummary(
                subject: subject,
                totalCards: totalCards,
                averageWeakness: averageWeakness,
                weakestTags: Array(weakestTags)
            )
        }
        .sorted { $0.subject < $1.subject }
    }

    private func dailySort(_ lhs: Flashcard, _ rhs: Flashcard) -> Bool {
        let lhsNeverReviewed = lhs.stats.lastReviewedAt == nil
        let rhsNeverReviewed = rhs.stats.lastReviewedAt == nil
        if lhsNeverReviewed != rhsNeverReviewed {
            return lhsNeverReviewed
        }

        if let lhsDate = lhs.stats.lastReviewedAt, let rhsDate = rhs.stats.lastReviewedAt, lhsDate != rhsDate {
            return lhsDate < rhsDate
        }

        if lhs.stats.weaknessScore != rhs.stats.weaknessScore {
            return lhs.stats.weaknessScore > rhs.stats.weaknessScore
        }

        return lhs.id.uuidString < rhs.id.uuidString
    }

    private func weakSpotsSort(_ lhs: Flashcard, _ rhs: Flashcard) -> Bool {
        if lhs.stats.weaknessScore != rhs.stats.weaknessScore {
            return lhs.stats.weaknessScore > rhs.stats.weaknessScore
        }

        if lhs.stats.incorrect != rhs.stats.incorrect {
            return lhs.stats.incorrect > rhs.stats.incorrect
        }

        let lhsReviewedAt = lhs.stats.lastReviewedAt ?? .distantPast
        let rhsReviewedAt = rhs.stats.lastReviewedAt ?? .distantPast
        if lhsReviewedAt != rhsReviewedAt {
            return lhsReviewedAt < rhsReviewedAt
        }

        return lhs.id.uuidString < rhs.id.uuidString
    }
}

enum StudyMode: String, Codable, CaseIterable {
    case daily
    case weakSpots
    case cram
}

extension StudyMode {
    var displayName: String {
        switch self {
        case .daily:
            return "Daily"
        case .weakSpots:
            return "Weak Spots"
        case .cram:
            return "Cram"
        }
    }

    var descriptionText: String {
        switch self {
        case .daily:
            return "Balanced cards for today"
        case .weakSpots:
            return "Prioritizes cards you miss"
        case .cram:
            return "Deck order, fast review"
        }
    }
}
