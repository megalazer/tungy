import SwiftUI

@main
struct TungyApp: App {
    @StateObject var appModel = AppModel(store: TungyStore.shared)

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appModel)
        }
    }
}
