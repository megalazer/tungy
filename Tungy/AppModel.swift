import FamilyControls
import Foundation

@MainActor
final class AppModel: ObservableObject {
    let store: TungyStore
    let blocker: ScreenTimeBlocker
    let flashcardEngine = FlashcardEngine()
    let dailyGate = DailyGate()

    @Published var streakCount: Int
    @Published var decks: [Deck]
    @Published var selectedDeckID: Deck.ID?
    @Published var studyMode: StudyMode
    @Published private(set) var studyCards: [Flashcard]
    @Published var isAnswerVisible: Bool
    @Published var dailyGoal: DailyGoal
    @Published var dailyProgress: DailyProgress

    var selectedDeck: Deck? {
        guard let selectedDeckID else { return decks.first }
        return decks.first { $0.id == selectedDeckID } ?? decks.first
    }

    var currentStudyCard: Flashcard? {
        studyCards.first
    }

    var subjectSummaries: [SubjectSummary] {
        flashcardEngine.subjectSummaries(decks: decks)
    }

    var isUnlockedForToday: Bool {
        dailyGate.isUnlocked(progress: dailyProgress, goal: dailyGoal)
    }

    var brainHealthPercent: Int {
        let requiredCards = max(1, dailyGoal.requiredCards)
        return min(100, Int((Double(dailyProgress.completedCards) / Double(requiredCards)) * 100.0))
    }

    var dailyStatusText: String {
        if blocker.hasSelection == false {
            return "Choose apps to enable blocking"
        }

        if case .denied = blocker.authorizationStatus {
            return "Permission needed to block apps"
        }

        if case .approved = blocker.authorizationStatus {
            return isUnlockedForToday ? "Unlocked for today" : "Study to unlock"
        }

        return "Permission needed to block apps"
    }

    var homeCallToActionTitle: String {
        isUnlockedForToday ? "Unlocked for today" : "Study to Unlock"
    }

    init(store: TungyStore, blocker: ScreenTimeBlocker) {
        self.store = store
        self.blocker = blocker
        self.streakCount = 0

        var loadedDecks = store.loadDecks()
        let shouldSeedDecks = loadedDecks.isEmpty
        if shouldSeedDecks {
            loadedDecks = Deck.seedDecks
        }

        self.decks = loadedDecks
        self.selectedDeckID = loadedDecks.first?.id
        self.studyMode = .daily
        self.studyCards = []
        self.isAnswerVisible = false
        self.dailyGoal = store.loadDailyGoal()

        let initialDayKey = DailyGate().dayKey(for: Date(), resetHour: self.dailyGoal.resetHour, calendar: .current)
        self.dailyProgress = store.loadDailyProgress() ?? .empty(dayKey: initialDayKey)

        if shouldSeedDecks {
            try? store.saveDecks(loadedDecks)
        }

        normalizeDailyProgress()
        refreshStudyQueue()
        enforceDailyBlocking()
    }

    func selectDeck(_ deckID: Deck.ID?) {
        selectedDeckID = deckID
        refreshStudyQueue()
    }

    func setStudyMode(_ mode: StudyMode) {
        studyMode = mode
        refreshStudyQueue()
    }

    func flipCurrentCard() {
        isAnswerVisible.toggle()
    }

    func recordStudyGrade(_ grade: ReviewGrade, at now: Date = Date(), calendar: Calendar = .current) {
        guard let currentStudyCard, let deckIndex = decks.firstIndex(where: { $0.id == selectedDeck?.id }) else { return }

        var deck = decks[deckIndex]
        flashcardEngine.record(grade, for: currentStudyCard.id, in: &deck, at: now)
        decks[deckIndex] = deck
        try? store.saveDecks(decks)

        let didUnlock = dailyGate.recordCompletedCard(progress: &dailyProgress, goal: dailyGoal, at: now, calendar: calendar)
        try? store.saveDailyProgress(dailyProgress)

        if didUnlock {
            blocker.clearShield()
        } else {
            enforceDailyBlocking(at: now, calendar: calendar)
        }

        if studyCards.isEmpty == false {
            studyCards.removeFirst()
        }
        isAnswerVisible = false

        if studyCards.isEmpty {
            refreshStudyQueue()
        }
    }

    func refreshStudyQueue(limit: Int = 20) {
        guard let selectedDeck else {
            studyCards = []
            isAnswerVisible = false
            return
        }

        studyCards = flashcardEngine.dueCards(in: selectedDeck, limit: limit, mode: studyMode)
        isAnswerVisible = false
    }

    func updateRequiredCards(_ requiredCards: Int) {
        dailyGoal.requiredCards = min(max(1, requiredCards), 50)
        try? store.saveDailyGoal(dailyGoal)
        normalizeDailyProgress()
        unlockIfGoalAlreadyMet(at: Date())
        enforceDailyBlocking()
    }

    func enforceDailyBlocking(at now: Date = Date(), calendar: Calendar = .current) {
        normalizeDailyProgress(at: now, calendar: calendar)

        if blocker.hasSelection == false {
            blocker.clearShield()
            return
        }

        if isUnlockedForToday {
            blocker.clearShield()
            return
        }

        guard isScreenTimeApproved else { return }
        blocker.applyShield()
    }

    func normalizeDailyProgress(at now: Date = Date(), calendar: Calendar = .current) {
        let todayKey = dailyGate.dayKey(for: now, resetHour: dailyGoal.resetHour, calendar: calendar)
        if dailyProgress.dayKey != todayKey {
            dailyProgress = .empty(dayKey: todayKey)
            try? store.saveDailyProgress(dailyProgress)
        }
    }

    private var isScreenTimeApproved: Bool {
        if case .approved = blocker.authorizationStatus {
            return true
        }
        return false
    }

    private func unlockIfGoalAlreadyMet(at now: Date) {
        if dailyProgress.completedCards >= max(1, dailyGoal.requiredCards), dailyProgress.unlockedAt == nil {
            dailyProgress.unlockedAt = now
            try? store.saveDailyProgress(dailyProgress)
        }
    }
}
