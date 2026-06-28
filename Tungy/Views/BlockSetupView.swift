import FamilyControls
import SwiftUI

struct BlockSetupView: View {
    @EnvironmentObject private var appModel: AppModel
    @EnvironmentObject private var blocker: ScreenTimeBlocker
    @State private var isPickerPresented = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    authorizationCard
                    selectionCard
                    actionCard
                }
                .padding(20)
            }
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationTitle("Block")
            .familyActivityPicker(isPresented: $isPickerPresented, selection: selectionBinding)
        }
    }

    private var selectionBinding: Binding<FamilyActivitySelection> {
        Binding(
            get: { blocker.selection },
            set: {
                blocker.updateSelection($0)
                appModel.enforceDailyBlocking()
            }
        )
    }

    private var authorizationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Screen Time Permission", systemImage: "lock.fill")
                .font(.title3.weight(.heavy))
                .foregroundStyle(TungyTheme.primary)

            LabeledContent("Status", value: authorizationStatusText)
                .font(.headline)

            if let message = blocker.authorizationErrorMessage {
                Text(message)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(TungyTheme.error)
            }

            Button {
                Task {
                    await blocker.requestAuthorization()
                    appModel.enforceDailyBlocking()
                }
            } label: {
                Text("Request Screen Time Permission")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(TungyTheme.primary)
        }
        .screenCard()
    }

    private var selectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Blocking Selection")
                .font(.title3.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)

            Button {
                isPickerPresented = true
            } label: {
                Text("Choose Apps to Block")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(TungyTheme.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Apps: \(blocker.selection.applicationTokens.count)")
                Text("Categories: \(blocker.selection.categoryTokens.count)")
                Text("Websites: \(blocker.selection.webDomainTokens.count)")
            }
            .font(.headline)
            .foregroundStyle(TungyTheme.onSurface)
        }
        .screenCard()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                guard isApproved, blocker.hasSelection else { return }
                blocker.applyShield()
            } label: {
                Text("Block Now")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(TungyTheme.primary)
            .disabled(!isApproved || !blocker.hasSelection)

            Button {
                blocker.clearShield()
            } label: {
                Text("Unblock")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(TungyTheme.secondary)
        }
        .screenCard()
    }

    private var authorizationStatusText: String {
        switch blocker.authorizationStatus {
        case .notDetermined:
            return "Not determined"
        case .approved:
            return "Approved"
        case .approvedWithDataAccess:
            return "Approved"
        case .denied:
            return "Denied"
        @unknown default:
            return "Not determined"
        }
    }

    private var isApproved: Bool {
        switch blocker.authorizationStatus {
        case .approved, .approvedWithDataAccess:
            return true
        default:
            return false
        }
    }
}

private extension View {
    func screenCard() -> some View {
        padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TungyTheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: TungyTheme.onSurface.opacity(0.14), radius: 0, x: 0, y: 4)
    }
}

#Preview {
    BlockSetupView()
        .environmentObject(ScreenTimeBlocker.shared)
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
}
