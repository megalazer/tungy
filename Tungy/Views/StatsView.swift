import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Label("Stats", systemImage: "chart.bar.fill")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(TungyTheme.primary)

                Text("Real usage reports arrive in the DeviceActivity branch. For now, Tungy shows the dashboard shell only.")
                    .foregroundStyle(TungyTheme.outline)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationTitle("Stats")
        }
    }
}

#Preview {
    StatsView()
}
