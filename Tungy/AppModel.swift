import Foundation

@MainActor
final class AppModel: ObservableObject {
    let store: TungyStore
    let blocker: ScreenTimeBlocker
    let flashcardEngine = FlashcardEngine()

    @Published var streakCount: Int
    @Published var decks: [Deck]
    @Published var selectedDeckID: Deck.ID?
    @Published var studyMode: StudyMode
    @Published private(set) var studyCards: [Flashcard]
    @Published var isAnswerVisible: Bool

    var selectedDeck: Deck? {
        guard let selectedDeckID else { return decks.first }
        return decks.first { $0.id == selectedDeckID } ?? decks.first
    }

    var currentStudyCard: Flashcard? {
        studyCards.first
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

        if shouldSeedDecks {
            try? store.saveDecks(loadedDecks)
        }

        refreshStudyQueue()
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

    func recordStudyGrade(_ grade: ReviewGrade, at now: Date = Date()) {
        guard let currentStudyCard, let deckIndex = decks.firstIndex(where: { $0.id == selectedDeck?.id }) else { return }

        var deck = decks[deckIndex]
        flashcardEngine.record(grade, for: currentStudyCard.id, in: &deck, at: now)
        decks[deckIndex] = deck
        try? store.saveDecks(decks)

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
}
