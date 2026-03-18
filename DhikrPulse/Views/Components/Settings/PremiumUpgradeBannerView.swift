import SwiftUI

struct PremiumUpgradeBannerView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @Binding var showingPremiumStore: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if !storeManager.isPro {
                Button {
                    showingPremiumStore = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: "crown.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DhikrPulse PRO'ya Geçin")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Sınırsız zikir, temalar, ısı haritası ve daha fazlası")
                                .font(.caption)
                                .foregroundColor(.themeSecondaryText)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.themeSecondaryText)
                            .font(.caption.bold())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.themeCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.yellow.opacity(0.6), .orange.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .padding(.horizontal)
            } else {
                Button {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    SettingsRowView(
                        icon: "creditcard.fill",
                        iconColor: .themeAccent,
                        title: "Aboneliği Yönet",
                        subtitle: "İptal, değiştirme veya yenileme",
                        trailing: .externalLink
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}
