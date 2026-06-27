import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Label("Stats", systemImage: "chart.bar.fill")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(TungyTheme.primary)

                    if appModel.subjectSummaries.isEmpty {
                        Text("Add cards to start studying")
                            .foregroundStyle(TungyTheme.outline)
                            .statsPanel()
                    } else {
                        ForEach(appModel.subjectSummaries) { summary in
                            SubjectSummaryCard(summary: summary)
                        }
                    }
                }
                .padding(20)
            }
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationTitle("Stats")
        }
    }
}

private struct SubjectSummaryCard: View {
    let summary: SubjectSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(summary.subject)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(TungyTheme.onSurface)
                Spacer()
                Text("\(summary.totalCards) cards")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TungyTheme.primary)
            }

            Text("Average weakness: \(Int((summary.averageWeakness * 100.0).rounded()))%")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TungyTheme.outline)

            if summary.weakestTags.isEmpty {
                Text("No weak spots yet")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TungyTheme.tertiaryContainer)
            } else {
                HStack {
                    ForEach(summary.weakestTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(TungyTheme.secondaryContainer)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .statsPanel()
    }
}

private extension View {
    func statsPanel() -> some View {
        padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TungyTheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: TungyTheme.onSurface.opacity(0.14), radius: 0, x: 0, y: 4)
    }
}

#Preview {
    StatsView()
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
}
