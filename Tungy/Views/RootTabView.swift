import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            BlockSetupView()
                .tabItem {
                    Label("Block", systemImage: "lock.fill")
                }

            StudyView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(TungyTheme.primary)
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
        .environmentObject(ScreenTimeBlocker.shared)
}
