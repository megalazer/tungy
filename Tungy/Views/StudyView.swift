import SwiftUI

struct StudyView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "timer")
                    .font(.system(size: 56))
                    .foregroundStyle(TungyTheme.primary)

                Text("Focus")
                    .font(.largeTitle.weight(.heavy))

                Text("Flash-card study unlocks blocked apps in the MVP.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(TungyTheme.outline)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(TungyTheme.background.ignoresSafeArea())
            .navigationTitle("Focus")
        }
    }
}

#Preview {
    StudyView()
}
