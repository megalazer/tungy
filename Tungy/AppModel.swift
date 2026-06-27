import Foundation

@MainActor
final class AppModel: ObservableObject {
    let store: TungyStore
    let blocker: ScreenTimeBlocker

    @Published var streakCount: Int

    init(store: TungyStore, blocker: ScreenTimeBlocker) {
        self.store = store
        self.blocker = blocker
        self.streakCount = 0
    }
}
