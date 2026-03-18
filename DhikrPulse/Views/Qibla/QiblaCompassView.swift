import SwiftUI
import CoreLocation

struct QiblaCompassView: View {
    @StateObject private var qiblaManager = QiblaManager()
    @State private var glowPulse: Bool = false
    
    // Haptic feedback
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic Background based on alignment
                let diff = abs(qiblaManager.qiblaAngle)
                let isAligned = (diff < 3.0 || diff > 357.0) && qiblaManager.authorizationStatus == .authorizedWhenInUse
                
                Color.themeBackground.ignoresSafeArea()
                
                if isAligned {
                    RadialGradient(
                        gradient: Gradient(colors: [Color.themeAccent.opacity(0.15), Color.clear]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 400
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.0), value: isAligned)
                }
                
                if qiblaManager.authorizationStatus == .notDetermined {
                    permissionRequestView
                } else if qiblaManager.authorizationStatus == .denied || qiblaManager.authorizationStatus == .restricted {
                    permissionDeniedView
                } else {
                    compassContent
                }
            }
            .navigationTitle("Kıble")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.themeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            qiblaManager.startUpdating()
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
        .onDisappear {
            qiblaManager.stopUpdating()
        }
    }
    
    private var permissionRequestView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.themeAccent.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.themeAccent)
                    .shadow(color: Color.themeAccent.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Text("Kıbleyi Bulalım")
                .font(.title2.weight(.bold))
                .foregroundColor(.themePrimaryText)
            
            Text("Kabe'nin yönünü hassas bir şekilde hesaplayabilmek için konumunuza ihtiyacımız var.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeSecondaryText)
                .padding(.horizontal, 40)
            
            Button {
                qiblaManager.requestPermission()
            } label: {
                Text("Konum İzni Ver")
                    .font(.headline)
                    .foregroundColor(Color.themeBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.themeAccent)
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
                    .shadow(color: Color.themeAccent.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var permissionDeniedView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 120, height: 120)
                Image(systemName: "location.slash.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Text("Konum İzni Gerekli")
                .font(.title2.weight(.bold))
                .foregroundColor(.themePrimaryText)
            
            Text("Kıble özelliğini kullanabilmek için Ayarlar'dan uygulamanın konum erişimine izin vermelisiniz.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeSecondaryText)
                .padding(.horizontal, 40)
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Ayarları Aç")
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(14)
                    .padding(.horizontal, 40)
                    .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    private var compassContent: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Yön bilgisi ve Kaaba ikonu
            let diff = abs(qiblaManager.qiblaAngle)
            let isAligned = diff < 3.0 || diff > 357.0 
            
            VStack(spacing: 16) {
                if isAligned {
                    ZStack {
                        Circle()
                            .fill(Color.themeAccent.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .scaleEffect(glowPulse ? 1.05 : 0.95)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPulse)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.themeAccent)
                            .transition(.scale.combined(with: .opacity))
                            .shadow(color: Color.themeAccent, radius: 10, x: 0, y: 0)
                            .onAppear {
                                triggerHaptic()
                            }
                    }
                    
                    Text("Kıble Yönündesiniz")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.themeAccent)
                        .padding(.top, 4)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color.themePrimaryText.opacity(0.05))
                            .frame(width: 80, height: 80)
                            
                        Image(systemName: "location.north.line.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.themeSecondaryText)
                    }
                    
                    Text("Telefonunuzu Döndürün")
                        .font(.title3.weight(.medium))
                        .foregroundColor(.themeSecondaryText)
                        .padding(.top, 4)
                }
                
                // Derece Bilgileri
                HStack(spacing: 40) {
                    VStack(spacing: 4) {
                        Text("Kıble")
                            .font(.caption)
                            .foregroundColor(.themeSecondaryText)
                        Text("\(Int(qiblaManager.qiblaDirection))°")
                            .font(.headline.monospacedDigit())
                            .foregroundColor(.themePrimaryText)
                    }
                    
                    Divider()
                        .frame(height: 30)
                        .background(Color.themePrimaryText.opacity(0.2))
                    
                    VStack(spacing: 4) {
                        Text("Yönünüz")
                            .font(.caption)
                            .foregroundColor(.themeSecondaryText)
                        Text("\(Int(qiblaManager.heading))°")
                            .font(.headline.monospacedDigit())
                            .foregroundColor(isAligned ? .themeAccent : .themePrimaryText)
                    }
                }
                .padding(.top, 10)
            }
            .frame(height: 180)
            .animation(.easeInOut, value: isAligned)
            
            // Modern Pusula Kadranı
            ZStack {
                // Dış Çerçeve (Bezel) Gölgeli ve Gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.themePrimaryText.opacity(0.08), Color.themePrimaryText.opacity(0.02)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 320, height: 320)
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.themePrimaryText.opacity(0.3), Color.themePrimaryText.opacity(0.05)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
                
                // Dönen İç Kadran (Kuzey her zaman Kuzeyi gösterir)
                ZStack {
                    // Derece Çizgileri
                    ForEach(0..<72) { tick in
                        let isMajor = tick % 18 == 0
                        Rectangle()
                            .fill(isMajor ? Color.themePrimaryText : Color.themePrimaryText.opacity(0.3))
                            .frame(width: isMajor ? 2 : 1, height: isMajor ? 14 : 6)
                            .offset(y: -140)
                            .rotationEffect(.degrees(Double(tick) * 5))
                    }
                    
                    // Yön Harfleri
                    Text("N").font(.system(size: 22, weight: .bold)).foregroundColor(.red).offset(y: -110).rotationEffect(.degrees(0))
                    Text("E").font(.system(size: 18, weight: .semibold)).foregroundColor(.themePrimaryText).offset(y: -110).rotationEffect(.degrees(90))
                    Text("S").font(.system(size: 18, weight: .semibold)).foregroundColor(.themePrimaryText).offset(y: -110).rotationEffect(.degrees(180))
                    Text("W").font(.system(size: 18, weight: .semibold)).foregroundColor(.themePrimaryText).offset(y: -110).rotationEffect(.degrees(270))
                    
                    // Kabe Göstergesi (Kadran üzerinde sabit durur, doğru hedefe bakar)
                    ZStack {
                        Circle()
                            .fill(Color.themeAccent.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "location.north.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.themeAccent)
                            .shadow(color: Color.themeAccent.opacity(0.6), radius: 5, x: 0, y: 0)
                    }
                    .offset(y: -114)
                    .rotationEffect(.degrees(qiblaManager.qiblaDirection))
                    
                    // Merkez Noktası
                    Circle()
                        .fill(Color.black)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle().stroke(Color.themePrimaryText.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                }
                .rotationEffect(.degrees(-qiblaManager.heading))
                // Animation for smooth compass rotation
                .animation(.easeOut(duration: 0.1), value: qiblaManager.heading)
                
                // Sabit Tepe Ok Noktası (Cihazın baktığı yön)
                VStack {
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isAligned ? .themeAccent : .themePrimaryText)
                        .shadow(color: isAligned ? Color.themeAccent.opacity(0.8) : Color.black.opacity(0.3), radius: isAligned ? 8 : 4, x: 0, y: 2)
                        .offset(y: -20)
                    Spacer()
                }
                .frame(width: 320, height: 350)
                .animation(.easeInOut, value: isAligned)
            }
            .padding(.bottom, 30)
            
            Spacer()
        }
    }
}

#Preview {
    QiblaCompassView()
}
