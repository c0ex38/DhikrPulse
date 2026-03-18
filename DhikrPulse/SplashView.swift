import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var circleScale = 0.1
    @State private var circleOpacity = 0.8
    
    // Binding or callback to let the App know splash is done
    @Binding var showMainApp: Bool
    
    var body: some View {
        ZStack {
            // Background color
            Color.themeBackground
                .ignoresSafeArea()
            
            // Animated Circles
            ZStack {
                Circle()
                    .stroke(Color.themeAccent.opacity(0.3), lineWidth: 2)
                    .frame(width: 250, height: 250)
                    .scaleEffect(circleScale)
                    .opacity(circleOpacity)
                
                Circle()
                    .stroke(Color.themeAccent.opacity(0.5), lineWidth: 4)
                    .frame(width: 200, height: 200)
                    .scaleEffect(circleScale * 1.2)
                    .opacity(circleOpacity * 0.8)
                
                // Centered App Icon / Logo
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.themeAccent)
                    
                    Text("DhikrPulse")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Kalbinizi ritimde tutun")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                        .italic()
                }
                .scaleEffect(size)
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.2)) {
                self.size = 1.0
                self.opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                self.circleScale = 1.5
                self.circleOpacity = 0.0
            }
            
            // Navigate to main app after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.showMainApp = true
                }
            }
        }
    }
}

#Preview {
    SplashView(showMainApp: .constant(false))
}
