import SwiftUI

struct ConfettiView: UIViewRepresentable {
    @Binding var trigger: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if trigger {
            fireConfetti(in: uiView)
            
            // Auto reset the trigger to allow consecutive firings
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // Partikül dökülme süresi
                if self.trigger {
                    self.trigger = false
                }
            }
        }
    }
    
    private func fireConfetti(in view: UIView) {
        let emitter = CAEmitterLayer()
        // Ekranın üstünden, tam ortasından dökülecek şekilde konumlandırıyoruz.
        // updateUIView tetiklediğinde bounds sıfır olabilirse diye windowScene yedeği koyuyoruz
        let width = view.window?.windowScene?.screen.bounds.width ?? UIScreen.main.bounds.width
        emitter.emitterPosition = CGPoint(x: width / 2, y: -30)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: width, height: 1)
        
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink, .systemOrange, .systemPurple, .systemTeal
        ]
        
        emitter.emitterCells = colors.map { color in
            let cell = CAEmitterCell()
            cell.birthRate = 20
            cell.lifetime = 4.0
            cell.velocity = 250
            cell.velocityRange = 100
            cell.yAcceleration = 200 // Gravity
            cell.emissionLongitude = .pi // Aşağı
            cell.emissionRange = .pi / 4 // Yayılma
            cell.spin = 2
            cell.spinRange = 4
            cell.scaleRange = 0.5
            cell.scale = 1.0
            cell.contents = UIImage.makeConfettiImage(color: color).cgImage
            return cell
        }
        
        view.layer.addSublayer(emitter)
        
        // Yarım saniye sonra patlamayı durdur (sadece patlayıp bitmesi için)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            emitter.birthRate = 0
        }
        
        // Emitter tamamen silinince ramdan temizle
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            emitter.removeFromSuperlayer()
        }
    }
}

extension UIImage {
    static func makeConfettiImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 8, height: 14) // Dikdörtgen konfeti
        let format = UIGraphicsImageRendererFormat()
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

#Preview {
    struct ConfettiPreview: View {
        @State private var trigger = false
        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                ConfettiView(trigger: $trigger).ignoresSafeArea()
                Button("Patlat") {
                    trigger = true
                }
                .font(.title)
                .buttonStyle(.borderedProminent)
            }
        }
    }
    return ConfettiPreview()
}
