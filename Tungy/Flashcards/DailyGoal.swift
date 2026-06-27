import Foundation

struct DailyGoal: Codable, Equatable {
    var requiredCards: Int
    var activeDeckIDs: [UUID]
    var resetHour: Int
}

struct DailyProgress: Codable, Equatable {
    var dayKey: String
    var completedCards: Int
    var unlockedAt: Date?
}

extension DailyGoal {
    static let `default` = DailyGoal(requiredCards: 5, activeDeckIDs: [], resetHour: 4)
}

extension DailyProgress {
    static func empty(dayKey: String) -> DailyProgress {
        DailyProgress(dayKey: dayKey, completedCards: 0, unlockedAt: nil)
    }
}
