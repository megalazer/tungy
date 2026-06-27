import SwiftUI

@main
struct TungyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var appModel = AppModel(store: TungyStore.shared, blocker: ScreenTimeBlocker.shared)

    var body: some Scene {
        WindowGroup {
            RootTabView()
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
