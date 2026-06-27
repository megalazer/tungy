import SwiftUI

@main
struct TungyApp: App {
    @StateObject var appModel = AppModel(store: TungyStore.shared, blocker: ScreenTimeBlocker.shared)

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
                .environmentObject(appModel.blocker)
        }
    }
}
