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
                    topOffendersCard
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
                Text("90%")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(TungyTheme.primary)
            }

            ProgressView(value: 0.9)
                .tint(TungyTheme.tertiaryContainer)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .cardStyle(background: TungyTheme.surfaceContainerLow)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Rot time", value: "2h 10m", symbolName: "iphone.gen3")
            StatCard(title: "Pickups", value: "37", symbolName: "hand.tap.fill")
            StatCard(title: "Focus time", value: "45m", symbolName: "timer")
        }
    }

    private var startFocusButton: some View {
        Button(action: {}) {
            Text("Start Focus")
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

    private var topOffendersCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Offenders")
                .font(.title3.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)

            OffenderRow(rank: 1, name: "Social", time: "1h 12m", color: TungyTheme.secondaryContainer)
            OffenderRow(rank: 2, name: "Video", time: "38m", color: TungyTheme.primaryContainer)
            OffenderRow(rank: 3, name: "Games", time: "20m", color: TungyTheme.tertiaryContainer)
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

private struct OffenderRow: View {
    let rank: Int
    let name: String
    let time: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.headline.weight(.heavy))
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(Circle())
            Text(name)
                .font(.body.weight(.semibold))
            Spacer()
            Text(time)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(TungyTheme.outline)
        }
        .foregroundStyle(TungyTheme.onSurface)
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
