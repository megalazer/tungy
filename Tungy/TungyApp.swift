import SwiftUI

@main
struct TungyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var appModel = AppModel(store: TungyStore.shared, blocker: ScreenTimeBlocker.shared)
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appModel)
            .environmentObject(appModel.blocker)
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    appModel.enforceDailyBlocking()
                }
            }
        }
    }
}
