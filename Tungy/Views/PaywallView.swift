import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: Plan = .yearly
    @State private var showRetentionOffer = false
    @State private var hasSeenRetentionOffer = false

    enum Plan: CaseIterable {
        case weekly, monthly, yearly
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .weekly: return "Weekly"
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
        
        var priceDisplay: String {
            switch self {
            case .weekly: return "$4.00"
            case .monthly: return "$9.99"
            case .yearly: return "$52.00"
            }
        }
        
        var subtitle: String {
            switch self {
            case .weekly: return "$4 / week"
            case .monthly: return "Billed monthly"
            case .yearly: return "$1 / week"
            }
        }
    }

    var body: some View {
        ZStack {
            TungyTheme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: handleClose) {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundColor(TungyTheme.outline)
                            .padding(12)
                            .background(Circle().fill(TungyTheme.surfaceContainerLow))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Title and Hero
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(TungyTheme.primary)
                    
                    Text("Unlock Tungy Premium")
                        .font(.title.bold())
                        .foregroundStyle(TungyTheme.onSurface)
                        .multilineTextAlignment(.center)
                    
                    Text("Supercharge your language learning and focus.")
                        .font(.body)
                        .foregroundStyle(TungyTheme.outline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Plan Selection
                VStack(spacing: 16) {
                    ForEach(Plan.allCases, id: \.self) { plan in
                        PlanRow(
                            plan: plan,
                            isSelected: selectedPlan == plan,
                            action: { selectedPlan = plan }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // CTA Button
                Button(action: {
                    // Handle purchase
                }) {
                    Text("Continue with \(selectedPlan.title)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(TungyTheme.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Footer
                Text("Auto-renews. Cancel anytime.")
                    .font(.caption)
                    .foregroundStyle(TungyTheme.outline)
                    .padding(.bottom, 8)
            }
            
            // Retention Offer Overlay
            if showRetentionOffer {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showRetentionOffer = false
                    }
                
                RetentionOfferView(
                    onAccept: {
                        // Handle retention offer purchase
                        showRetentionOffer = false
                    },
                    onDecline: {
                        showRetentionOffer = false
                        dismiss()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(), value: showRetentionOffer)
    }
    
    private func handleClose() {
        if !hasSeenRetentionOffer {
            hasSeenRetentionOffer = true
            showRetentionOffer = true
        } else {
            dismiss()
        }
    }
}

struct PlanRow: View {
    let plan: PaywallView.Plan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.title)
                        .font(.headline)
                        .foregroundStyle(isSelected ? TungyTheme.onSurface : TungyTheme.onSurface)
                    
                    Text(plan.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(isSelected ? TungyTheme.onSurface.opacity(0.8) : TungyTheme.outline)
                }
                
                Spacer()
                
                Text(plan.priceDisplay)
                    .font(.title3.bold())
                    .foregroundStyle(isSelected ? TungyTheme.onSurface : TungyTheme.onSurface)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? TungyTheme.primaryContainer : TungyTheme.surfaceContainer)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? TungyTheme.primary : TungyTheme.outline.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct RetentionOfferView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Wait! Special Offer")
                .font(.title2.bold())
                .foregroundStyle(TungyTheme.onSurface)
            
            Text("Get Tungy Premium for just **$2.08 / month** (billed annually as $24.99). Don't miss out on this limited time retention offer.")
                .font(.body)
                .foregroundStyle(TungyTheme.outline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                Button(action: onAccept) {
                    Text("Claim $2.08 / month")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(TungyTheme.primary)
                        .cornerRadius(16)
                }
                
                Button(action: onDecline) {
                    Text("No thanks, I'll pass")
                        .font(.subheadline.bold())
                        .foregroundColor(TungyTheme.outline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(TungyTheme.surfaceContainer)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    PaywallView()
}
