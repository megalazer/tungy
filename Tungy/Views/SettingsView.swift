import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Goal") {
                    Stepper(value: Binding(
                        get: { appModel.dailyGoal.requiredCards },
                        set: { appModel.updateRequiredCards($0) }
                    ), in: 1...50) {
                        LabeledContent("Daily Cards", value: "\(appModel.dailyGoal.requiredCards)")
                    }

                    Text("Resets at 04:00")
                        .foregroundStyle(TungyTheme.outline)
                }

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
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
}
