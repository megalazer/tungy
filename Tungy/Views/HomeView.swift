import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    topBar
                    mascotHero
                    brainHealthCard
                    statsGrid
                    startFocusButton
                    blockingStatusCard
                }
                .padding(20)
            }
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var topBar: some View {
        HStack {
            Text("Tungy")
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(TungyTheme.secondary)
                Text("\(appModel.streakCount) day")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(TungyTheme.onSurface)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(TungyTheme.secondaryContainer)
            .clipShape(Capsule())
            .raisedShadow()
        }
    }

    private var mascotHero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(TungyTheme.primaryContainer)
                    .frame(width: 132, height: 132)
                    .raisedShadow()
                Image(systemName: "figure.wave.circle.fill")
                    .font(.system(size: 76))
                    .foregroundStyle(TungyTheme.primary)
            }

            Text("Less scrolling, more living")
                .font(.title3.weight(.bold))
                .foregroundStyle(TungyTheme.onSurface)
        }
        .frame(maxWidth: .infinity)
    }

    private var brainHealthCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Brain Health")
                        .font(.headline)
                        .foregroundStyle(TungyTheme.onSurface)
                    Text("Today's focus score")
                        .font(.subheadline)
                        .foregroundStyle(TungyTheme.outline)
                }
                Spacer()
                Text("\(appModel.brainHealthPercent)%")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(TungyTheme.primary)
            }

            ProgressView(value: Double(appModel.brainHealthPercent) / 100.0)
                .tint(TungyTheme.tertiaryContainer)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .cardStyle(background: TungyTheme.surfaceContainerLow)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Cards", value: "\(appModel.dailyProgress.completedCards)", symbolName: "checkmark.circle.fill")
            StatCard(title: "Goal", value: "\(appModel.dailyGoal.requiredCards)", symbolName: "target")
            StatCard(title: "Status", value: appModel.dailyStatusText, symbolName: "lock.fill")
        }
    }

    private var startFocusButton: some View {
        Button(action: {}) {
            Text(appModel.homeCallToActionTitle)
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.white)
                .background(TungyTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .raisedShadow()
        }
        .buttonStyle(.plain)
    }

    private var blockingStatusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Blocking Status")
                .font(.title3.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)

            Text(appModel.dailyStatusText)
                .font(.headline.weight(.bold))
                .foregroundStyle(appModel.isUnlockedForToday ? TungyTheme.tertiaryContainer : TungyTheme.secondary)

            Text("Finish today's cards to release selected apps. Real usage reports arrive later.")
                .font(.subheadline)
                .foregroundStyle(TungyTheme.outline)
        }
        .cardStyle(background: TungyTheme.surfaceContainerLow)
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundStyle(TungyTheme.primary)
            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(TungyTheme.outline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 112)
        .cardStyle(background: TungyTheme.surfaceContainer)
    }
}


private extension View {
    func cardStyle(background: Color) -> some View {
        self
            .padding(18)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .raisedShadow()
    }

    func raisedShadow() -> some View {
        shadow(color: TungyTheme.onSurface.opacity(0.14), radius: 0, x: 0, y: 4)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
}
