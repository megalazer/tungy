import Foundation

struct DailyGate {
    func dayKey(for date: Date, resetHour: Int, calendar: Calendar) -> String {
        let boundedResetHour = min(max(resetHour, 0), 23)
        let hour = calendar.component(.hour, from: date)
        let assignedDate: Date
        if hour < boundedResetHour {
            assignedDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        } else {
            assignedDate = date
        }

        let components = calendar.dateComponents([.year, .month, .day], from: assignedDate)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    func isUnlocked(progress: DailyProgress, goal: DailyGoal) -> Bool {
        progress.completedCards >= max(1, goal.requiredCards) && progress.unlockedAt != nil
    }

    func recordCompletedCard(progress: inout DailyProgress, goal: DailyGoal, at now: Date, calendar: Calendar) -> Bool {
        let currentDayKey = dayKey(for: now, resetHour: goal.resetHour, calendar: calendar)
        if progress.dayKey != currentDayKey {
            progress = .empty(dayKey: currentDayKey)
        }

        let wasUnlocked = isUnlocked(progress: progress, goal: goal)
        progress.completedCards += 1

        if wasUnlocked == false && progress.completedCards >= max(1, goal.requiredCards) {
            progress.unlockedAt = now
            return true
        }

        return false
    }
}
