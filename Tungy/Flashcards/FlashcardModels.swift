import Foundation

struct Deck: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var subject: String
    var cards: [Flashcard]
}

struct Flashcard: Identifiable, Codable, Equatable {
    var id: UUID
    var front: String
    var back: String
    var tags: [String]
    var stats: CardStats
}

struct CardStats: Codable, Equatable {
    var attempts: Int
    var correct: Int
    var incorrect: Int
    var lastReviewedAt: Date?
    var weaknessScore: Double
}

enum ReviewGrade: String, Codable, CaseIterable {
    case again
    case hard
    case good
}

extension CardStats {
    static let fresh = CardStats(attempts: 0, correct: 0, incorrect: 0, lastReviewedAt: nil, weaknessScore: 0.0)
}

extension ReviewGrade {
    var displayName: String {
        switch self {
        case .again:
            return "Again"
        case .hard:
            return "Hard"
        case .good:
            return "Good"
        }
    }
}

extension Deck {
    static let seedDecks: [Deck] = [
        Deck(
            id: UUID(uuidString: "7C54F5A4-5212-4C93-8C67-17638E8D2D1E")!,
            title: "Python Basics",
            subject: "Python",
            cards: [
                Flashcard(id: UUID(uuidString: "87E4DF5C-7D03-43EC-9F13-F08CB47292EE")!, front: "What keyword defines a function in Python?", back: "def", tags: [], stats: .fresh),
                Flashcard(id: UUID(uuidString: "622D83E1-A3F1-4799-A02D-6513F86F256C")!, front: "What data type is returned by len([1, 2, 3])?", back: "int", tags: [], stats: .fresh),
                Flashcard(id: UUID(uuidString: "A7DC3DEE-8104-4B56-9361-3DBEA783B420")!, front: "What symbol starts a comment in Python?", back: "#", tags: [], stats: .fresh),
                Flashcard(id: UUID(uuidString: "27D214A0-C108-4711-9927-78F9A0D0B7E2")!, front: "What collection type stores key/value pairs?", back: "dict", tags: [], stats: .fresh),
                Flashcard(id: UUID(uuidString: "D6B17669-8F9A-47B9-84A2-472E6F86A6F4")!, front: "What exception appears when a name is not defined?", back: "NameError", tags: [], stats: .fresh)
            ]
        )
    ]
}
