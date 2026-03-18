import SwiftUI
import AudioToolbox

struct CounterView: View {
    // Current dhikr item passed conceptually, but we read real data from VM
    var dhikrItemId: String?
    
    // Uygulama geneli seçili zikrin ID'sini değiştirebilmek için
    @AppStorage("active_dhikr_id") private var activeDhikrIdAsString: String = ""
    
    @EnvironmentObject private var viewModel: DhikrViewModel
    @EnvironmentObject private var storeManager: StoreManager
    @StateObject private var interstitialAd = InterstitialAd()
    
    // Current Dhikr calculated property
    private var dhikrItem: DhikrItem? {
        let activeId = dhikrItemId ?? activeDhikrIdAsString
        return viewModel.dhikrs.first { $0.id == activeId }
    }
    
    // Ayarlar
    @AppStorage("haptic_enabled") private var hapticEnabled: Bool = true
    @AppStorage("sound_enabled") private var soundEnabled: Bool = false
    @AppStorage("premium_touchpad_style") private var touchpadStyle: String = "classic"
    @AppStorage("background_type") private var selectedBackground: String = ZikirBackgroundType.classic.rawValue
    
    // UI State
    @State private var scale: CGFloat = 1.0
    @State private var showConfetti: Bool = false
    
    // Haptic Feedback
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            // Background
            DynamicBackgroundView(type: ZikirBackgroundType(rawValue: selectedBackground) ?? .classic)
            
            ConfettiView(trigger: $showConfetti)
                .ignoresSafeArea()
                .zIndex(100)
            
            VStack {
                // Top Navigation Bar
                HStack {
                    // Left X Button
                    CircleIconButton(icon: "xmark") {
                        /* Dismiss if presented modally */
                    }
                    
                    Spacer()
                    
                    // Title Area
                    Menu {
                        ForEach(viewModel.dhikrs) { item in
                            Button {
                                if let id = item.id {
                                    activeDhikrIdAsString = id
                                }
                            } label: {
                                // Seçili olanın yanına checkmark koy
                                if item.id == (dhikrItemId ?? activeDhikrIdAsString) {
                                    Label(item.name, systemImage: "checkmark")
                                } else {
                                    Text(item.name)
                                }
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Text(dhikrItem?.name.uppercased() ?? "ZİKİR SEÇİN")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(.themePrimaryText)
                                    .tracking(2)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption2.bold())
                                    .foregroundColor(.themeSecondaryText)
                            }
                            
                            // Small green indicator line
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.themeAccent)
                                .frame(width: 30, height: 3)
                        }
                    }
                    
                    Spacer()
                    
                    // Right Settings Button
                    CircleIconButton(icon: "gearshape.fill") {
                        /* Open Settings */
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // Numbers Area
                VStack(spacing: 8) {
                    Text("\(dhikrItem?.currentCount ?? 0)")
                        .font(.system(size: 110, weight: .semibold, design: .rounded))
                        .foregroundColor(.themePrimaryText)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: dhikrItem?.currentCount)
                    
                    Text("HEDEF: \(dhikrItem?.targetCount ?? 0)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.themeSecondaryText)
                        .tracking(1)
                }
                
                Spacer()
                
                // Main Tap Button
                Button(action: incrementCounter) {
                    Group {
                        if storeManager.isPro && touchpadStyle == "wood" {
                            // Ahşap Tema
                            Circle()
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [Color.brown, Color.brown.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 250, height: 250)
                                .shadow(color: Color.brown.opacity(0.3), radius: 30, x: 0, y: 15)
                                .overlay(
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.themePrimaryText.opacity(0.7))
                                )
                        } else if storeManager.isPro && touchpadStyle == "water" {
                            // Su Damlası Tema
                            Circle()
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 250, height: 250)
                                .shadow(color: Color.blue.opacity(0.4), radius: 30, x: 0, y: 15)
                                .overlay(
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.themePrimaryText.opacity(0.7))
                                )
                        } else {
                            // Klasik Tema (Yeşil)
                            Circle()
                                .fill(Color.themeAccent)
                                .frame(width: 250, height: 250)
                                .shadow(color: Color.themeAccent.opacity(0.3), radius: 30, x: 0, y: 15)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "touchid") // Fingerprint approximation
                                            .font(.system(size: 50, weight: .light))
                                            .foregroundColor(Color.themeBackground)
                                        
                                        Text("DOKUN")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color.themeBackground)
                                            .tracking(1)
                                    }
                                )
                        }
                    }
                    .scaleEffect(scale)
                }
                .buttonStyle(PlainButtonStyle()) // Custom handling via scale
                .pressEvents {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        scale = 0.95
                    }
                } onRelease: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        scale = 1.0
                    }
                }
                
                Spacer()
                
                // Undo & Reset Buttons
                HStack(spacing: 40) {
                    // Undo
                    VStack(spacing: 8) {
                        Button(action: undoCounter) {
                            Circle()
                                .stroke(Color.themeSecondaryText.opacity(0.3), lineWidth: 1)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "arrow.uturn.backward")
                                        .foregroundColor(Color.themeAccent)
                                        .font(.system(size: 20))
                                )
                        }
                        Text("GERİ AL")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.themeSecondaryText)
                            .tracking(1)
                    }
                    .disabled(dhikrItem?.currentCount == 0 || dhikrItem == nil)
                    .opacity(dhikrItem?.currentCount == 0 || dhikrItem == nil ? 0.4 : 1.0)
                    
                    // Reset
                    VStack(spacing: 8) {
                        Button(action: resetCounter) {
                            Circle()
                                .stroke(Color.themeSecondaryText.opacity(0.3), lineWidth: 1)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(Color.themeAccent)
                                        .font(.system(size: 20))
                                )
                        }
                        Text("SIFIRLA")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.themeSecondaryText)
                            .tracking(1)
                    }
                }
                .padding(.bottom, 10)
                
                // AdMob Banner for Free Users
                if !storeManager.isPro {
                    AdBannerView(adUnitID: "ca-app-pub-3565786409265176/9551521802")
                        .frame(width: 320, height: 50)
                        .background(Color.black.opacity(0.1))
                        .padding(.bottom, 10)
                }
            }
        }
        .onAppear {
            impactMedium.prepare()
            notificationFeedback.prepare()
        }
    }
    
    // MARK: - Actions
    private func incrementCounter() {
        guard var currentItem = dhikrItem else { return }
        
        currentItem.currentCount += 1
        
        // Update Firestore
        viewModel.updateDhikr(currentItem)
        viewModel.logDailyZikir(count: 1)
        
        let completed = currentItem.currentCount >= currentItem.targetCount
        playSoundIfEnabled(completed: completed)
        
        if completed {
            if hapticEnabled {
                // Sadece o an hedefe ulaştıysa notification ver. Önceden ulaştıysa normal impact ver.
                if currentItem.currentCount == currentItem.targetCount {
                    notificationFeedback.notificationOccurred(.success)
                    showConfetti = true
                    
                    // Show Interstitial if not pro
                    if !storeManager.isPro {
                        interstitialAd.showAd()
                    }
                } else {
                    impactMedium.impactOccurred()
                }
            }
        } else {
            if hapticEnabled {
                impactMedium.impactOccurred()
            }
        }
    }
    
    private func undoCounter() {
        guard var currentItem = dhikrItem, currentItem.currentCount > 0 else { return }
        
        currentItem.currentCount -= 1
        
        // Update Firestore
        viewModel.updateDhikr(currentItem)
        viewModel.logDailyZikir(count: -1)
        
        if hapticEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    private func resetCounter() {
        guard var currentItem = dhikrItem else { return }
        
        let oldCount = currentItem.currentCount
        currentItem.currentCount = 0
        
        // Update Firestore
        viewModel.updateDhikr(currentItem)
        viewModel.logDailyZikir(count: -oldCount)
        
        if hapticEnabled {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
    
    private func playSoundIfEnabled(completed: Bool) {
        if soundEnabled {
            // Basit sistem sesi, 1104 = keyboard click, 1054 = pop
            AudioServicesPlaySystemSound(completed ? 1054 : 1104)
        }
    }
    
}

// MARK: - Preview setup
#Preview {
    CounterView()
        .environmentObject(DhikrViewModel())
}
