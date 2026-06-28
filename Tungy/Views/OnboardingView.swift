import SwiftUI
import UIKit
import StoreKit

enum OnboardingSlide: Int, CaseIterable {
    case welcome
    case turnAddiction
    case hijackAttention
    case mainGoal
    case screenTimeEffect
    case controlPattern
    case screenTimeCost
    case dailyScreenTime
    case attentionProfile
    case lifeInfographic
    case willpowerLoop
    case howTungyWorks
    case reviewPrompt
    case firstWeekPlan
    case commitment
}

enum OnboardingGoal: String, CaseIterable {
    case improveFocus = "Improve focus"
    case reduceScrolling = "Reduce scrolling"
    case sleepBetter = "Sleep better"
    case beMindful = "Be mindful"
    case beProductive = "Be productive"
    case getSmarter = "Get smarter"

    var symbolName: String {
        switch self {
        case .improveFocus: return "scope"
        case .reduceScrolling: return "iphone.slash"
        case .sleepBetter: return "moon.zzz.fill"
        case .beMindful: return "leaf.fill"
        case .beProductive: return "checkmark.seal.fill"
        case .getSmarter: return "brain.head.profile"
        }
    }
}

enum ScreenTimeImpact: String, CaseIterable {
    case loseFocus = "I lose focus"
    case wasteTime = "I waste time"
    case sleepLater = "I sleep later"
    case feelAnxious = "I feel anxious"
    case memoryWorse = "My memory feels worse"

    var symbolName: String {
        switch self {
        case .loseFocus: return "eye.trianglebadge.exclamationmark.fill"
        case .wasteTime: return "hourglass"
        case .sleepLater: return "bed.double.fill"
        case .feelAnxious: return "waveform.path.ecg"
        case .memoryWorse: return "memories"
        }
    }
}

enum LossTime: String, CaseIterable {
    case mornings = "Mornings"
    case duringDay = "During the day"
    case notSure = "Not sure"

    var symbolName: String {
        switch self {
        case .mornings: return "sunrise.fill"
        case .duringDay: return "sun.max.fill"
        case .notSure: return "questionmark.circle.fill"
        }
    }
}

enum ReductionAttempt: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case fewTimes = "A few times"

    var symbolName: String {
        switch self {
        case .yes: return "checkmark.circle.fill"
        case .no: return "xmark.circle.fill"
        case .fewTimes: return "arrow.triangle.2.circlepath.circle.fill"
        }
    }
}

struct AttentionProfile: Equatable {
    let title: String
    let summary: String
    let symbolName: String
}

func makeAttentionProfile(
    goal: OnboardingGoal?,
    impact: ScreenTimeImpact?,
    lossTime: LossTime?,
    dailyHours: Double
) -> AttentionProfile {
    if lossTime == .mornings {
        return AttentionProfile(
            title: "The Morning Scroller",
            summary: "Your first attention battle happens before momentum starts.",
            symbolName: "sunrise.fill"
        )
    } else if impact == .sleepLater {
        return AttentionProfile(
            title: "The Night Loop",
            summary: "Your phone steals rest, then tiredness makes tomorrow harder.",
            symbolName: "moon.zzz.fill"
        )
    } else if goal == .getSmarter {
        return AttentionProfile(
            title: "The Builder",
            summary: "You want your screen time to compound into skill.",
            symbolName: "brain.head.profile"
        )
    } else if dailyHours >= 6 {
        return AttentionProfile(
            title: "The Deep Feed Diver",
            summary: "Your biggest opportunity is reclaiming blocks of time.",
            symbolName: "hourglass"
        )
    } else {
        return AttentionProfile(
            title: "The Attention Rebuilder",
            summary: "You are ready to make your phone work for you.",
            symbolName: "arrow.triangle.2.circlepath"
        )
    }
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentSlideIndex = 0
    @State private var selectedGoal: OnboardingGoal?
    @State private var selectedImpact: ScreenTimeImpact?
    @State private var selectedLossTime: LossTime?
    @State private var selectedReductionAttempt: ReductionAttempt?
    @State private var dailyHours: Double = 4
    @State private var lastHapticHour: Int = 4
    @State private var reviewRequested = false
    @State private var mascotFloat = false
    @State private var phoneIntoBook = false
    @State private var chipsVisible = false
    @State private var loopInterrupted = false
    @State private var showFinalBooks = false

    private var currentSlide: OnboardingSlide {
        OnboardingSlide(rawValue: currentSlideIndex) ?? .welcome
    }

    private var progressFraction: CGFloat {
        CGFloat(currentSlideIndex + 1) / CGFloat(OnboardingSlide.allCases.count)
    }

    private var attentionProfile: AttentionProfile {
        makeAttentionProfile(
            goal: selectedGoal,
            impact: selectedImpact,
            lossTime: selectedLossTime,
            dailyHours: dailyHours
        )
    }

    private var canContinue: Bool {
        switch currentSlide {
        case .mainGoal:
            return selectedGoal != nil
        case .screenTimeEffect:
            return selectedImpact != nil
        case .controlPattern:
            return selectedLossTime != nil && selectedReductionAttempt != nil
        case .commitment:
            return false
        default:
            return true
        }
    }

    var body: some View {
        ZStack {
            TungyTheme.background.ignoresSafeArea()

            VStack(spacing: 18) {
                progressBar

                ScrollView(showsIndicators: false) {
                    slideView
                        .id(currentSlideIndex)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }

                bottomControls
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            mascotFloat = true
            phoneIntoBook = true
            chipsVisible = true
            loopInterrupted = true
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(TungyTheme.surfaceContainer)
                Capsule()
                    .fill(TungyTheme.primary)
                    .frame(width: max(8, proxy.size.width * progressFraction))
                    .animation(.spring(response: 0.42, dampingFraction: 0.82), value: progressFraction)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    @ViewBuilder
    private var slideView: some View {
        switch currentSlide {
        case .welcome:
            welcomeSlide
        case .turnAddiction:
            turnAddictionSlide
        case .hijackAttention:
            hijackAttentionSlide
        case .mainGoal:
            mainGoalSlide
        case .screenTimeEffect:
            screenTimeEffectSlide
        case .controlPattern:
            controlPatternSlide
        case .screenTimeCost:
            screenTimeCostSlide
        case .dailyScreenTime:
            dailyScreenTimeSlide
        case .attentionProfile:
            attentionProfileSlide
        case .lifeInfographic:
            lifeInfographicSlide
        case .willpowerLoop:
            willpowerLoopSlide
        case .howTungyWorks:
            howTungyWorksSlide
        case .reviewPrompt:
            reviewPromptSlide
        case .firstWeekPlan:
            firstWeekPlanSlide
        case .commitment:
            commitmentSlide
        }
    }

    private var bottomControls: some View {
        Group {
            if currentSlide == .commitment {
                EmptyView()
            } else {
                continueButton(enabled: canContinue) {
                    advanceSlide()
                }
            }
        }
    }

    private func advanceSlide() {
        guard canContinue, currentSlideIndex < OnboardingSlide.allCases.count - 1 else { return }
        Haptics.lightTap()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
            currentSlideIndex += 1
        }
        Haptics.selection()
    }

    private func continueButton(title: String = "Continue", enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            guard enabled else { return }
            action()
        }) {
            Text(title)
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .foregroundStyle(.white)
                .background(enabled ? TungyTheme.primary : TungyTheme.outline.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .raisedShadow(enabled: enabled)
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
    }

    private var welcomeSlide: some View {
        VStack(spacing: 20) {
            MascotView(isFloating: mascotFloat)
            VibratingText(
                text: "Meet Tungy.",
                font: .system(size: 42, weight: .heavy, design: .rounded),
                alignment: .center
            )
            Text("Less scrolling. More learning. More life.")
                .font(.title3.weight(.bold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
        }
    }

    private var turnAddictionSlide: some View {
        VStack(spacing: 22) {
            MascotView(isFloating: mascotFloat)
            VibratingText(
                text: "Most apps try to block you. Tungy makes the urge useful.",
                font: .system(size: 30, weight: .heavy, design: .rounded),
                alignment: .center
            )
            Text("Instead of deleting your distractions or forcing another timer, Tungy redirects the habit loop into quick learning wins.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
            phoneToBookAnimation
        }
    }

    private var phoneToBookAnimation: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(TungyTheme.surfaceContainerLow)
                .raisedShadow()
            HStack(spacing: 26) {
                Image(systemName: "iphone")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(TungyTheme.secondary)
                    .offset(x: phoneIntoBook ? 18 : -18)
                Image(systemName: "arrow.right")
                    .font(.title.weight(.heavy))
                    .foregroundStyle(TungyTheme.primary)
                    .opacity(phoneIntoBook ? 1 : 0.35)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(TungyTheme.tertiaryContainer)
                    .scaleEffect(phoneIntoBook ? 1.08 : 0.94)
            }
            .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: phoneIntoBook)
        }
        .frame(height: 132)
    }

    private var hijackAttentionSlide: some View {
        VStack(spacing: 22) {
            VibratingText(
                text: "You are not weak. Apps are engineered to hijack attention.",
                font: .system(size: 31, weight: .heavy, design: .rounded),
                alignment: .center
            )
            Text("Tungy helps you take control and turn that addiction into a boon: learn throughout the day without breaking out pomodoro tools.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    delayedChip("Triggers", index: 0, color: TungyTheme.secondaryContainer)
                    delayedChip("Dopamine", index: 1, color: TungyTheme.secondaryContainer)
                    delayedChip("Endless feeds", index: 2, color: TungyTheme.secondaryContainer)
                }
                delayedChip("Learning loop", index: 3, color: TungyTheme.tertiaryContainer)
            }
        }
    }

    private func delayedChip(_ text: String, index: Int, color: Color) -> some View {
        Text(text)
            .font(.subheadline.weight(.heavy))
            .foregroundStyle(TungyTheme.onSurface)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(color.opacity(0.85))
            .clipShape(Capsule())
            .opacity(chipsVisible ? 1 : 0)
            .offset(y: chipsVisible ? 0 : 12)
            .animation(.spring(response: 0.35, dampingFraction: 0.72).delay(Double(index) * 0.16), value: chipsVisible)
    }

    private var mainGoalSlide: some View {
        choiceSlide(
            title: "What is your main goal with Tungy?",
            subtitle: "Pick the win Tungy should help you build first.",
            options: OnboardingGoal.allCases,
            selection: selectedGoal,
            titleForOption: { $0.rawValue },
            symbolForOption: { $0.symbolName },
            action: { selectedGoal = $0 }
        )
    }

    private var screenTimeEffectSlide: some View {
        choiceSlide(
            title: "How does screen time affect you the most?",
            subtitle: "Tungy will shape your profile around this pattern.",
            options: ScreenTimeImpact.allCases,
            selection: selectedImpact,
            titleForOption: { $0.rawValue },
            symbolForOption: { $0.symbolName },
            action: { selectedImpact = $0 }
        )
    }

    private var controlPatternSlide: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What describes you?")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
            Text("Answer two quick checks so Tungy can make the right attention profile.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.outline)

            Text("When do you lose control most often?")
                .font(.headline.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)
            ForEach(LossTime.allCases, id: \.self) { option in
                ChoiceCard<LossTime>(
                    title: option.rawValue,
                    symbolName: option.symbolName,
                    isSelected: selectedLossTime == option
                ) {
                    Haptics.mediumTap()
                    selectedLossTime = option
                }
            }

            Text("Have you tried to reduce screen time before?")
                .font(.headline.weight(.heavy))
                .foregroundStyle(TungyTheme.onSurface)
                .padding(.top, 8)
            ForEach(ReductionAttempt.allCases, id: \.self) { option in
                ChoiceCard<ReductionAttempt>(
                    title: option.rawValue,
                    symbolName: option.symbolName,
                    isSelected: selectedReductionAttempt == option
                ) {
                    Haptics.mediumTap()
                    selectedReductionAttempt = option
                }
            }
        }
    }

    private var screenTimeCostSlide: some View {
        AnimatedInfoCards(
            title: "Too much screen time taxes the brain.",
            cards: [
                InfoCardContent(symbolName: "memories", title: "Memory", body: "Constant switching makes it harder to store what matters."),
                InfoCardContent(symbolName: "scope", title: "Focus", body: "Short rewards train your brain to seek the next hit."),
                InfoCardContent(symbolName: "cloud.moon.fill", title: "Mood", body: "Late scrolling and comparison can drain sleep and calm.")
            ]
        )
    }

    private var dailyScreenTimeSlide: some View {
        VStack(spacing: 24) {
            Text("How long is your daily screen time?")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text("\(dailyHours, specifier: "%.1f") hours/day")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.primary)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(TungyTheme.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .raisedShadow()
            Slider(value: $dailyHours, in: 1...12, step: 0.5)
                .tint(TungyTheme.primary)
                .onChange(of: dailyHours) { newValue in
                    let roundedHour = Int(newValue.rounded())
                    if roundedHour != lastHapticHour {
                        lastHapticHour = roundedHour
                        Haptics.selection()
                    }
                }
            HStack {
                Text("1h")
                Spacer()
                Text("12h")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(TungyTheme.outline)
        }
        .cardStyle(background: TungyTheme.surfaceContainerLow)
    }

    private var attentionProfileSlide: some View {
        VStack(spacing: 22) {
            MascotView(isFloating: mascotFloat)
            Image(systemName: attentionProfile.symbolName)
                .font(.system(size: 48, weight: .heavy))
                .foregroundStyle(TungyTheme.primary)
                .frame(width: 84, height: 84)
                .background(TungyTheme.primaryContainer.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            Text(attentionProfile.title)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text(attentionProfile.summary)
                .font(.title3.weight(.bold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
        }
    }

    private var lifeInfographicSlide: some View {
        LifeInfographicView(dailyHours: dailyHours)
    }

    private var willpowerLoopSlide: some View {
        VStack(spacing: 24) {
            Text("Willpower does not beat dopamine loops for long.")
                .font(.system(size: 33, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text("Feeds are designed to reward tiny pulls, taps, and swipes. Tungy changes the loop instead of asking you to white-knuckle it.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
            ZStack {
                Circle()
                    .stroke(TungyTheme.secondaryContainer, lineWidth: 18)
                    .frame(width: 190, height: 190)
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 104, weight: .bold))
                    .foregroundStyle(TungyTheme.secondary)
                    .rotationEffect(.degrees(loopInterrupted ? 360 : 0))
                    .animation(.linear(duration: 3).repeatForever(autoreverses: false), value: loopInterrupted)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 54, weight: .heavy))
                    .foregroundStyle(TungyTheme.tertiaryContainer)
                    .scaleEffect(loopInterrupted ? 1.15 : 0.75)
                    .animation(.spring(response: 0.45, dampingFraction: 0.55).delay(0.4), value: loopInterrupted)
            }
        }
    }

    private var howTungyWorksSlide: some View {
        VStack(spacing: 16) {
            Text("How Tungy works")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
            VStack(spacing: 12) {
                comparisonCard(title: "Blockers rebound", body: "When the block ends, the craving is still there.", symbolName: "lock.open.fill")
                comparisonCard(title: "Timers get ignored", body: "A timer warns you, then you choose the feed anyway.", symbolName: "timer")
                comparisonCard(title: "Tungy retrains", body: "We turn unlock moments into learning reps so your behavior changes.", symbolName: "brain.head.profile")
            }
            Text("Built for learning and focus, not punishment.")
                .font(.headline.weight(.heavy))
                .foregroundStyle(.white)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(TungyTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .raisedShadow()
            authorityRow
            Text("Inspired by attention, habit, and learning research from leading universities.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(TungyTheme.outline)
                .multilineTextAlignment(.center)
        }
    }

    private func comparisonCard(title: String, body: String, symbolName: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbolName)
                .font(.title2.weight(.heavy))
                .foregroundStyle(TungyTheme.primary)
                .frame(width: 48, height: 48)
                .background(TungyTheme.primaryContainer.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(TungyTheme.onSurface)
                Text(body)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TungyTheme.outline)
            }
            Spacer(minLength: 0)
        }
        .cardStyle(background: TungyTheme.surfaceContainerLow)
    }

    private var authorityRow: some View {
        HStack(spacing: 8) {
            ForEach(["Oxford", "Harvard", "Cambridge"], id: \.self) { label in
                VStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.title3)
                    Text(label)
                        .font(.caption.weight(.heavy))
                }
                .foregroundStyle(TungyTheme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(TungyTheme.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }

    private var reviewPromptSlide: some View {
        VStack(spacing: 22) {
            MascotView(isFloating: mascotFloat)
            Text("Want Tungy to keep improving?")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text("A quick review helps us build the kinder alternative to doomscrolling.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
            Button {
                requestReview()
            } label: {
                HStack {
                    Image(systemName: reviewRequested ? "checkmark.circle.fill" : "star.fill")
                    Text(reviewRequested ? "Thanks — you're helping Tungy grow." : "Leave a quick review")
                }
                .font(.headline.weight(.heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundStyle(.white)
                .background(reviewRequested ? TungyTheme.tertiaryContainer : TungyTheme.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .raisedShadow()
            }
            .buttonStyle(.plain)
        }
    }

    private func requestReview() {
        reviewRequested = true
        Haptics.success()
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            return
        }
        SKStoreReviewController.requestReview(in: scene)
    }

    private var firstWeekPlanSlide: some View {
        AnimatedInfoCards(
            title: "This week Tungy helps you regain control.",
            cards: [
                InfoCardContent(symbolName: "hand.raised.fill", title: "Catch the scroll", body: "Notice the unlock moment before it owns you."),
                InfoCardContent(symbolName: "book.closed.fill", title: "Trade it for a rep", body: "Use that impulse for a tiny learning win."),
                InfoCardContent(symbolName: "chart.line.uptrend.xyaxis", title: "Build proof", body: "Watch your streak, focus score, and confidence grow.")
            ]
        )
    }

    private var commitmentSlide: some View {
        VStack(spacing: 24) {
            Text("Hold to stop scrolling.")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text("Make it official: your phone works for your brain now.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
                .cardStyle(background: TungyTheme.surfaceContainerLow)
            ZStack(alignment: .top) {
                MascotView(isFloating: mascotFloat)
                    .padding(.top, 80)
                BooksStackAnimation(showBooks: showFinalBooks)
            }
            .frame(height: 270)
            HoldToCommitButton(label: "Hold to commit") {
                showFinalBooks = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    hasCompletedOnboarding = true
                }
            }
        }
    }

    private func choiceSlide<Option: Hashable>(
        title: String,
        subtitle: String,
        options: [Option],
        selection: Option?,
        titleForOption: @escaping (Option) -> String,
        symbolForOption: @escaping (Option) -> String,
        action: @escaping (Option) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
            Text(subtitle)
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.outline)
            ForEach(options, id: \.self) { option in
                ChoiceCard<Option>(
                    title: titleForOption(option),
                    symbolName: symbolForOption(option),
                    isSelected: selection == option
                ) {
                    Haptics.mediumTap()
                    action(option)
                }
            }
        }
    }
}

private struct Haptics {
    static func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    static func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

private struct VibratingText: View {
    let text: String
    let font: Font
    let alignment: TextAlignment
    let characterDelay: UInt64 = 22_000_000

    @State private var visibleCount = 0
    @State private var jitter = false

    private var characters: [(offset: Int, element: Character)] {
        Array(text.enumerated())
    }

    var body: some View {
        CharacterWrapLayout(horizontalAlignment: alignment == .center ? .center : .leading) {
            ForEach(characters, id: \.offset) { item in
                let isVisible = item.offset < visibleCount
                let isNewest = item.offset >= max(0, visibleCount - 2) && item.offset < visibleCount && visibleCount < characters.count

                Text(String(item.element))
                    .font(font)
                    .foregroundStyle(TungyTheme.onSurface)
                    .opacity(isVisible ? 1 : 0)
                    .offset(
                        x: isNewest ? (jitter ? 1.2 : -1.2) : 0,
                        y: isNewest ? (jitter ? -0.8 : 0.8) : 0
                    )
                    .animation(
                        isNewest ? .easeInOut(duration: 0.05).repeatCount(3, autoreverses: true) : .default,
                        value: jitter
                    )
            }
        }
        .multilineTextAlignment(alignment)
        .task(id: text) {
            await revealCharacters()
        }
    }

    private func revealCharacters() async {
        await MainActor.run {
            visibleCount = 0
            jitter = false
        }
        for index in characters.indices {
            try? await Task.sleep(nanoseconds: characterDelay)
            await MainActor.run {
                visibleCount = index + 1
                jitter.toggle()
            }
        }
        await MainActor.run {
            jitter = false
        }
    }
}

private struct CharacterWrapLayout: Layout {
    var horizontalAlignment: HorizontalAlignment = .center
    var spacing: CGFloat = 0

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 320
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var widestRow: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0 && rowWidth + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                widestRow = max(widestRow, rowWidth)
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width
            rowHeight = max(rowHeight, size.height)
        }

        totalHeight += rowHeight
        widestRow = max(widestRow, rowWidth)
        return CGSize(width: min(maxWidth, max(widestRow, 1)), height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var rows: [[(LayoutSubview, CGSize)]] = [[]]
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth > 0 && rowWidth + size.width > bounds.width {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append((subview, size))
            rowWidth += size.width
        }

        var y = bounds.minY
        for row in rows where !row.isEmpty {
            let rowHeight = row.map(\.1.height).max() ?? 0
            let rowWidth = row.reduce(CGFloat(0)) { $0 + $1.1.width }
            let startX: CGFloat
            switch horizontalAlignment {
            case .center:
                startX = bounds.minX + max(0, (bounds.width - rowWidth) / 2)
            case .trailing:
                startX = bounds.maxX - rowWidth
            default:
                startX = bounds.minX
            }

            var x = startX
            for (subview, size) in row {
                subview.place(
                    at: CGPoint(x: x, y: y + (rowHeight - size.height) / 2),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width
            }
            y += rowHeight + spacing
        }
    }
}

private struct MascotView: View {
    let isFloating: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(TungyTheme.primaryContainer)
                .frame(width: 160, height: 160)
                .raisedShadow()
            Image(systemName: "figure.wave.circle.fill")
                .font(.system(size: 92))
                .foregroundStyle(TungyTheme.primary)
            if UIImage(named: "tungy") != nil {
                Image("tungy")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 150, maxHeight: 150)
            }
        }
        .offset(y: isFloating ? -8 : 8)
        .animation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true), value: isFloating)
        .frame(maxWidth: .infinity)
    }
}

private struct ChoiceCard<Option: Hashable>: View {
    let title: String
    let symbolName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbolName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(TungyTheme.primary)
                    .frame(width: 44, height: 44)
                    .background(TungyTheme.primaryContainer.opacity(0.35))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(TungyTheme.onSurface)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(TungyTheme.primary)
                }
            }
            .padding(14)
            .background(isSelected ? TungyTheme.primaryContainer.opacity(0.18) : TungyTheme.surfaceContainerLow)
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? TungyTheme.primary : TungyTheme.outline.opacity(0.18), lineWidth: isSelected ? 2 : 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .scaleEffect(isSelected ? 1.035 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.72), value: isSelected)
            .raisedShadow()
        }
        .buttonStyle(.plain)
    }
}

private struct HoldToCommitButton: View {
    let label: String
    let onComplete: () -> Void

    @GestureState private var isPressing = false
    @State private var isHolding = false
    @State private var holdProgress: CGFloat = 0
    @State private var didComplete = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TungyTheme.surfaceContainer)
                    .frame(height: 58)
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TungyTheme.primary)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(x: holdProgress, y: 1, anchor: .leading)
                    .frame(height: 58)
                Text(didComplete ? "Committed" : label)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .raisedShadow()
            .gesture(holdGesture)
            Text("Keep holding for 2 seconds")
                .font(.caption.weight(.bold))
                .foregroundStyle(TungyTheme.outline)
        }
    }

    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isPressing) { _, state, _ in
                state = true
            }
            .onChanged { _ in
                guard !isHolding, !didComplete else { return }
                isHolding = true
                Haptics.mediumTap()
                withAnimation(.linear(duration: 2.0)) {
                    holdProgress = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    guard isHolding, !didComplete else { return }
                    didComplete = true
                    Haptics.success()
                    onComplete()
                }
            }
            .onEnded { _ in
                isHolding = false
                guard !didComplete else { return }
                Haptics.warning()
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    holdProgress = 0
                }
            }
    }
}

private struct BooksStackAnimation: View {
    let showBooks: Bool

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundStyle(index.isMultiple(of: 2) ? TungyTheme.primary : TungyTheme.tertiaryContainer)
                    .offset(y: showBooks ? CGFloat(96 - (index * 20)) : 140)
                    .rotationEffect(.degrees(showBooks ? Double(index - 2) * 4 : 0))
                    .opacity(showBooks ? 1 : 0)
                    .animation(
                        .spring(response: 0.38, dampingFraction: 0.68).delay(Double(index) * 0.18),
                        value: showBooks
                    )
            }
        }
        .frame(height: 150)
    }
}

private struct InfoCardContent: Identifiable {
    let id = UUID()
    let symbolName: String
    let title: String
    let body: String
}

private struct AnimatedInfoCards: View {
    let title: String
    let cards: [InfoCardContent]
    @State private var visibleCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.leading)
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                HStack(spacing: 14) {
                    Image(systemName: card.symbolName)
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(TungyTheme.primary)
                        .frame(width: 48, height: 48)
                        .background(TungyTheme.primaryContainer.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.title)
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(TungyTheme.onSurface)
                        Text(card.body)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(TungyTheme.outline)
                    }
                    Spacer(minLength: 0)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(TungyTheme.tertiaryContainer)
                }
                .cardStyle(background: TungyTheme.surfaceContainerLow)
                .opacity(index < visibleCount ? 1 : 0)
                .offset(y: index < visibleCount ? 0 : 14)
                .animation(.spring(response: 0.35, dampingFraction: 0.75), value: visibleCount)
            }
        }
        .task {
            visibleCount = 0
            for index in cards.indices {
                try? await Task.sleep(nanoseconds: UInt64(index) * 120_000_000 + 120_000_000)
                await MainActor.run {
                    visibleCount = index + 1
                    Haptics.selection()
                }
            }
        }
    }
}

private struct LifeInfographicView: View {
    let dailyHours: Double
    @State private var animateBars = false
    @State private var displayedPhoneYears: Double = 0
    @State private var displayedRegainYears: Double = 0

    private let yearsRemaining = 80 - 25

    private var phoneYears: Double {
        dailyHours * Double(yearsRemaining) / 24
    }

    private var regainYears: Double {
        phoneYears * 0.25
    }

    private var moneyValue: Double {
        regainYears * 365 * 2 * 25
    }

    var body: some View {
        VStack(spacing: 18) {
            Text("Your time is still yours.")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text("Using a simple 80-year life estimate")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(TungyTheme.outline)
            VStack(spacing: 16) {
                animatedBar(label: "Years left", valueText: "55 years", color: TungyTheme.primary, fraction: 1)
                animatedBar(label: "On your phone", valueText: String(format: "%.1f years", displayedPhoneYears), color: TungyTheme.secondary, fraction: phoneYears / Double(yearsRemaining))
                animatedBar(label: "Tungy can help reclaim", valueText: String(format: "%.1f years", displayedRegainYears), color: TungyTheme.tertiaryContainer, fraction: regainYears / Double(yearsRemaining))
            }
            .cardStyle(background: TungyTheme.surfaceContainerLow)
            Text("At \(dailyHours, specifier: "%.1f") hours/day, that is about \(phoneYears, specifier: "%.1f") years of life on your phone.")
                .font(.body.weight(.semibold))
                .foregroundStyle(TungyTheme.onSurface)
                .multilineTextAlignment(.center)
            Text("Good news: if Tungy helps reclaim even 25%, that is about \(regainYears, specifier: "%.1f") years back and roughly $\(moneyValue, specifier: "%.0f") of time value.")
                .font(.headline.weight(.heavy))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(18)
                .background(TungyTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .raisedShadow()
        }
        .onAppear {
            displayedPhoneYears = 0
            displayedRegainYears = 0
            animateBars = false
            withAnimation(.easeOut(duration: 0.9)) {
                animateBars = true
                displayedPhoneYears = phoneYears
                displayedRegainYears = regainYears
            }
        }
    }

    private func animatedBar(label: String, valueText: String, color: Color, fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.heavy))
                Spacer()
                Text(valueText)
                    .font(.subheadline.weight(.heavy))
            }
            .foregroundStyle(TungyTheme.onSurface)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(TungyTheme.surfaceContainer)
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * CGFloat(max(0.04, min(1, fraction))) * (animateBars ? 1 : 0))
                }
            }
            .frame(height: 16)
        }
    }
}

private extension View {
    func cardStyle(background: Color) -> some View {
        self
            .padding(18)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .raisedShadow()
    }

    func raisedShadow(enabled: Bool = true) -> some View {
        shadow(color: enabled ? TungyTheme.onSurface.opacity(0.14) : .clear, radius: 0, x: 0, y: 4)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppModel(store: TungyStore(suiteName: ""), blocker: ScreenTimeBlocker.shared))
        .environmentObject(ScreenTimeBlocker.shared)
}
