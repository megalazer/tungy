import SwiftUI

struct StudyView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    progressPanel
                    deckPicker
                    modePicker
                    studyCard
                }
                .padding(20)
            }
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationTitle("Focus")
        }
    }

    private var progressPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appModel.isUnlockedForToday ? "Unlocked for today" : "\(appModel.dailyProgress.completedCards)/\(appModel.dailyGoal.requiredCards) cards")
                .font(.title3.weight(.heavy))
                .foregroundStyle(appModel.isUnlockedForToday ? TungyTheme.tertiaryContainer : TungyTheme.primary)

            Text(appModel.dailyStatusText)
                .font(.subheadline)
                .foregroundStyle(TungyTheme.outline)
        }
        .studyPanel()
    }

    private var deckPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Deck")
                .font(.headline.weight(.bold))

            Picker("Deck", selection: Binding(
                get: { appModel.selectedDeck?.id },
                set: { appModel.selectDeck($0) }
            )) {
                ForEach(appModel.decks) { deck in
                    Text(deck.title).tag(Optional(deck.id))
                }
            }
            .pickerStyle(.menu)
        }
        .studyPanel()
    }

    private var modePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mode")
                .font(.headline.weight(.bold))

            Picker("Mode", selection: Binding(
                get: { appModel.studyMode },
                set: { appModel.setStudyMode($0) }
            )) {
                ForEach(StudyMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text(appModel.studyMode.descriptionText)
                .font(.subheadline)
                .foregroundStyle(TungyTheme.outline)
        }
        .studyPanel()
    }

    @ViewBuilder
    private var studyCard: some View {
        if appModel.decks.flatMap(\.cards).isEmpty {
            Text("Add cards to start studying")
                .font(.title3.weight(.bold))
                .foregroundStyle(TungyTheme.outline)
                .frame(maxWidth: .infinity, minHeight: 220)
                .studyPanel()
        } else if let card = appModel.currentStudyCard {
            VStack(spacing: 18) {
                Text(appModel.isAnswerVisible ? card.back : card.front)
                    .font(.title2.weight(.heavy))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .padding()
                    .background(TungyTheme.surfaceContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                Button(appModel.isAnswerVisible ? "Hide Answer" : "Flip Card") {
                    appModel.flipCurrentCard()
                }
                .buttonStyle(.bordered)
                .tint(TungyTheme.primary)

                if appModel.isAnswerVisible {
                    HStack(spacing: 10) {
                        gradeButton(.again)
                        gradeButton(.hard)
                        gradeButton(.good)
                    }
                }
            }
            .studyPanel()
        } else {
            Text("Add cards to start studying")
                .font(.title3.weight(.bold))
                .foregroundStyle(TungyTheme.outline)
                .frame(maxWidth: .infinity, minHeight: 220)
                .studyPanel()
        }
    }

    private func gradeButton(_ grade: ReviewGrade) -> some View {
        Button(grade.displayName) {
            appModel.recordStudyGrade(grade)
        }
        .buttonStyle(.borderedProminent)
        .tint(tint(for: grade))
    }

    private func tint(for grade: ReviewGrade) -> Color {
        switch grade {
        case .again:
            return TungyTheme.error
        case .hard:
            return TungyTheme.secondary
        case .good:
            return TungyTheme.tertiaryContainer
        }
    }
}

private extension View {
    func studyPanel() -> some View {
        padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TungyTheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: TungyTheme.onSurface.opacity(0.14), radius: 0, x: 0, y: 4)
    }
}

#Preview {
    StudyView()
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
}
