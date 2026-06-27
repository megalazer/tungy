import FamilyControls
import Foundation
import ManagedSettings

@MainActor
final class ScreenTimeBlocker: ObservableObject {
    static let shared = ScreenTimeBlocker()

    @Published private(set) var authorizationStatus: AuthorizationStatus
    @Published private(set) var selection = FamilyActivitySelection()
    @Published var authorizationErrorMessage: String?

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty || !selection.webDomainTokens.isEmpty
    }

    private static let selectionKey = "screenTime.selection.v1"
    private let store: TungyStore
    private let managedSettingsStore = ManagedSettingsStore()

    init(store: TungyStore = TungyStore.shared) {
        self.store = store
        self.authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        self.selection = FamilyActivitySelection()
        loadPersistedSelection()
    }

    func requestAuthorization() async {
        authorizationErrorMessage = nil
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            if case .denied = authorizationStatus {
                authorizationErrorMessage = "Screen Time permission is needed before Tungy can block apps."
            }
        } catch {
            authorizationStatus = AuthorizationCenter.shared.authorizationStatus
            authorizationErrorMessage = "Screen Time permission is needed before Tungy can block apps."
        }
    }

    func updateSelection(_ newSelection: FamilyActivitySelection) {
        selection = newSelection
        persistSelection()
    }

    func applyShield() {
        managedSettingsStore.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        managedSettingsStore.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    func clearShield() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        managedSettingsStore.shield.webDomains = nil
    }

    private func loadPersistedSelection() {
        guard let data = store.data(forKey: Self.selectionKey) else {
            selection = FamilyActivitySelection()
            return
        }

        do {
            selection = try PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            store.removeValue(forKey: Self.selectionKey)
            selection = FamilyActivitySelection()
        }
    }

    private func persistSelection() {
        do {
            let data = try PropertyListEncoder().encode(selection)
            store.setData(data, forKey: Self.selectionKey)
        } catch {
            store.removeValue(forKey: Self.selectionKey)
        }
    }
}
