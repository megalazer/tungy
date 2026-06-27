import Foundation

@MainActor
final class AppModel: ObservableObject {
    let store: TungyStore

    @Published var streakCount: Int

    init(store: TungyStore) {
        self.store = store
        self.streakCount = 0
    }
}
