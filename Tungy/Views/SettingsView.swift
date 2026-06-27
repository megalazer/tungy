import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Storage") {
                    LabeledContent("App Group") {
                        Text(appModel.store.isUsingFallbackDefaults ? "Fallback defaults" : "group.com.tungy.app")
                            .foregroundStyle(TungyTheme.outline)
                    }
                }
            }
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .background(TungyTheme.background.ignoresSafeArea())
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppModel(store: TungyStore(suiteName: "")))
}
