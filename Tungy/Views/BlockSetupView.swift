import SwiftUI

struct BlockSetupView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Label("Block distracting apps", systemImage: "lock.fill")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(TungyTheme.primary)

                Text("Choose apps in the next step, then Tungy will keep them shielded until your daily cards are done.")
                    .foregroundStyle(TungyTheme.outline)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationTitle("Block")
        }
    }
}

#Preview {
    BlockSetupView()
}
