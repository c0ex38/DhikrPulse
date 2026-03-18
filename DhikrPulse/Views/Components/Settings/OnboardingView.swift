import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    
    @State private var selectedPage = 0
    @State private var notificationGranted = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                // Atla (Skip) Butonu
                HStack {
                    Spacer()
                    Button("Atla") {
                        completeOnboarding()
                    }
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
                    .padding()
                    .opacity(selectedPage < 2 ? 1 : 0)
                }
                
                // Kaydırmalı TabView
                TabView(selection: $selectedPage) {
                    onboardingPage(
                        imageName: "heart.fill",
                        title: "DhikrPulse'a Hoş Geldiniz",
                        description: "Telefonunuzu modern bir zikirmatik olarak kullanarak manevi hedeflerinize ulaşın. Sade, şık ve her zaman yanınızda."
                    )
                    .tag(0)
                    
                    onboardingPage(
                        imageName: "chart.bar.fill",
                        title: "İlerlemenizi Takip Edin",
                        description: "Günlük hedefler belirleyin, seriler (streaks) oluşturun ve başarımların kilidini açarak manevi istikrarınızı koruyun."
                    )
                    .tag(1)
                    
                    notificationPage
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.easeInOut, value: selectedPage)
                
                // Alt Kontrol Butonları
                VStack(spacing: 16) {
                    if selectedPage < 2 {
                        Button {
                            withAnimation {
                                selectedPage += 1
                            }
                        } label: {
                            Text("İleri")
                                .font(.headline)
                                .foregroundColor(Color.themeBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.themeAccent)
                                .cornerRadius(12)
                        }
                    } else {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Hemen Başla")
                                .font(.headline)
                                .foregroundColor(Color.themeBackground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.themeAccent)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    // Standart Onboarding Sayfası
    private func onboardingPage(imageName: String, title: String, description: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.themeAccent.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: imageName)
                    .font(.system(size: 70))
                    .foregroundColor(.themeAccent)
            }
            .padding(.bottom, 20)
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // Bildirim İzni İsteyen Özel 3. Sayfa
    private var notificationPage: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.themeAccent.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: notificationGranted ? "bell.fill" : "bell.badge.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.themeAccent)
            }
            .padding(.bottom, 20)
            
            Text("Akıllı Hatırlatıcılar")
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Günlük zikir hedeflerinizi unutmamak için bildirimlere izin verin. (İsteğe bağlı, dilediğiniz zaman ayarlardan değiştirebilirsiniz)")
                .font(.body)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if !notificationGranted {
                Button {
                    NotificationManager.shared.requestAuthorization { granted in
                        self.notificationGranted = granted
                    }
                } label: {
                    Text("Bildirimlere İzin Ver")
                        .font(.subheadline.bold())
                        .foregroundColor(.themeAccent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.themeAccent, lineWidth: 1.5)
                        )
                }
                .padding(.top, 10)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("İzin Verildi")
                }
                .foregroundColor(.green)
                .font(.subheadline.bold())
                .padding(.top, 10)
            }
            
            Spacer()
        }
    }
    
    private func completeOnboarding() {
        // Yumuşak geçişle state güncellenir
        withAnimation(.easeOut(duration: 0.5)) {
            hasSeenOnboarding = true
        }
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
