import SwiftUI

struct ContentView: View {
    // MARK: - State Properties
    // Veri kalıcılığı için @State yerine @AppStorage kullanıyoruz (UserDefaults tabanlı)
    @AppStorage("dhikr_count") private var count: Int = 0
    @AppStorage("dhikr_target") private var target: Int = 33
    @State private var showResetAlert: Bool = false
    @State private var pulseOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    
    // MARK: - Haptic Generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack {
                // Header (Target, Undo, Reset)
                HStack {
                    // Target Selection Button
                    Menu {
                        Button("Serbest (Hedef Yok)") { changeTarget(to: 0) }
                        Button("33") { changeTarget(to: 33) }
                        Button("99") { changeTarget(to: 99) }
                        Button("1000") { changeTarget(to: 1000) }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "bullseye")
                            Text(target == 0 ? "Serbest" : "Hedef: \(target)")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Undo Button
                    Button(action: undoCounter) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(count > 0 ? .orange : .gray.opacity(0.3))
                    }
                    .disabled(count == 0)
                    .padding(.trailing, 8)
                    
                    // Reset Button
                    Button(action: { showResetAlert = true }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
                .padding()
                
                Spacer()
                
                // Main Counter Display
                VStack(spacing: 10) {
                    Text(isTargetReached ? "Hedefe Ulaşıldı!" : " ")
                        .font(.headline)
                        .foregroundColor(.green)
                        .animation(.easeInOut, value: isTargetReached)
                    
                    Text("\(count)")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundColor(isTargetReached ? .green : .primary)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                        .padding(.horizontal)
                        .contentTransition(.numericText()) // Smooth number transition in iOS 16+
                        .animation(.snappy, value: count)
                    
                    Text("Zikir Nabzı")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(count == 0 ? 0 : 1)
                }
                
                Spacer()
                
                // Big Tap Area
                Button(action: incrementCounter) {
                    ZStack {
                        // Pulse Ring Effect
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                            .frame(width: 250, height: 250)
                            .scaleEffect(pulseScale)
                            .opacity(pulseOpacity)
                        
                        // Main Tap Button
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 220, height: 220)
                            .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 10)
                        
                        VStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.themePrimaryText)
                            
                            Text("DOKUN")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.themePrimaryText)
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle()) // Custom button style for physical feedback
                .padding(.bottom, 50)
            }
        }
        .alert("Sayacı Sıfırla", isPresented: $showResetAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sıfırla", role: .destructive) {
                resetCounter()
            }
        } message: {
            Text("Zikir sayacını sıfırlamak istediğinize emin misiniz?")
        }
        .onAppear {
            prepareHaptics()
        }
    }
    
    // MARK: - Computed Properties
    private var isTargetReached: Bool {
        return target > 0 && count > 0 && count % target == 0
    }
    
    // MARK: - Actions
    private func incrementCounter() {
        count += 1
        
        // Haptic Feedback
        if target > 0 && count % target == 0 {
            notificationFeedback.notificationOccurred(.success)
        } else {
            impactMedium.impactOccurred()
        }
        
        // Pulse Effect Animation
        pulseScale = 1.0
        pulseOpacity = 1.0
        
        withAnimation(.easeOut(duration: 0.6)) {
            pulseScale = 1.5
            pulseOpacity = 0.0
        }
    }
    
    private func undoCounter() {
        if count > 0 {
            count -= 1
            impactLight.impactOccurred()
        }
    }
    
    private func resetCounter() {
        count = 0
        impactHeavy.impactOccurred()
    }
    
    private func changeTarget(to newTarget: Int) {
        target = newTarget
        impactLight.impactOccurred()
    }
    
    private func prepareHaptics() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationFeedback.prepare()
    }
}

// MARK: - Custom Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}