import SwiftUI

struct DynamicBackgroundView: View {
    let type: ZikirBackgroundType
    @EnvironmentObject private var storeManager: StoreManager
    
    // Animasyon durumları
    @State private var animateGradient1 = false
    @State private var animateGradient2 = false
    
    var body: some View {
        ZStack {
            // Taban renk
            Color.themeBackground.ignoresSafeArea()
            
            // Seçilen tipe göre katman ekle (eğer Premium ise)
            if type != .classic && storeManager.isPro {
                switch type {
                case .islamic:
                    islamicPattern
                case .dynamicMesh:
                    dynamicMesh
                case .darkTexture:
                    darkTexture
                case .classic:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Islamic Pattern
    // Şık ve sade bir tekrarlayan geometrik etki
    private var islamicPattern: some View {
        GeometryReader { geometry in
            Path { path in
                let size = 60.0
                let cols = Int(geometry.size.width / size) + 2
                let rows = Int(geometry.size.height / size) + 2
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * size
                        let y = CGFloat(row) * size
                        
                        // Basit sekizgen yıldız benzeri bir çizim
                        path.move(to: CGPoint(x: x + size/2, y: y))
                        path.addLine(to: CGPoint(x: x + size, y: y + size/2))
                        path.addLine(to: CGPoint(x: x + size/2, y: y + size))
                        path.addLine(to: CGPoint(x: x, y: y + size/2))
                        path.closeSubpath()
                        
                        // İç kare
                        path.addRect(CGRect(x: x + size * 0.25, y: y + size * 0.25, width: size * 0.5, height: size * 0.5))
                    }
                }
            }
            .stroke(Color.themeAccent.opacity(0.15), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Dynamic Mesh (iOS Lock Screen style)
    private var dynamicMesh: some View {
        ZStack {
            // Blob 1
            Circle()
                .fill(Color.themeAccent.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: animateGradient1 ? 100 : -100, y: animateGradient1 ? -150 : 150)
            
            // Blob 2
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: animateGradient2 ? -150 : 150, y: animateGradient2 ? 200 : -200)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) {
                animateGradient1.toggle()
            }
            withAnimation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true)) {
                animateGradient2.toggle()
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Dark Texture / Noise
    private var darkTexture: some View {
        ZStack {
            // Kumlanma filtresi benzeri etki
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .ignoresSafeArea()
            
            // Radial gradient ile hafif bir ışık huzmesi
            RadialGradient(
                gradient: Gradient(colors: [Color.themeAccent.opacity(0.2), .clear]),
                center: .topLeading,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
}
