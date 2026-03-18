import SwiftUI

struct AboutLinksSectionView: View {
    @EnvironmentObject private var storeManager: StoreManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "info.circle", title: "HAKKINDA")
            
            VStack(spacing: 0) {
                Button {
                    storeManager.restorePurchases()
                } label: {
                    SettingsRowView(
                        icon: "arrow.clockwise",
                        iconColor: .blue,
                        title: "Satın Almaları Geri Yükle",
                        subtitle: "Önceki aboneliğinizi kurtarın",
                        trailing: .chevron
                    )
                }
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                Button {
                    // App Store URL for Rating
                    if let url = URL(string: "https://apps.apple.com/app/id123456789") { // TODO: Replace ID
                        UIApplication.shared.open(url)
                    }
                } label: {
                    SettingsRowView(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Uygulamayı Değerlendirin",
                        subtitle: "App Store'da puanlayın",
                        trailing: .externalLink
                    )
                }
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                Button {
                    shareApp()
                } label: {
                    SettingsRowView(
                        icon: "square.and.arrow.up",
                        iconColor: .green,
                        title: "Arkadaşlarına Öner",
                        subtitle: "DhikrPulse'ı paylaşın",
                        trailing: .chevron
                    )
                }
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                Button {
                    if let url = URL(string: "https://dhikrpulse.app/privacy") { // TODO: Replace URL
                        UIApplication.shared.open(url)
                    }
                } label: {
                    SettingsRowView(
                        icon: "hand.raised.fill",
                        iconColor: .purple,
                        title: "Gizlilik Politikası",
                        subtitle: "Verilerinizi nasıl kullandığımız",
                        trailing: .externalLink
                    )
                }
            }
            .background(Color.themeCard)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    private func shareApp() {
        let text = "DhikrPulse - Dijital zikir ve dua uygulaması! Hemen indir: https://apps.apple.com/app/id123456789" // TODO: Replace ID
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            // Tablet/Pad compatibility for UIActivityViewController popover root
            activityController.popoverPresentationController?.sourceView = root.view
            activityController.popoverPresentationController?.sourceRect = CGRect(x: root.view.bounds.midX, y: root.view.bounds.midY, width: 0, height: 0)
            
            root.present(activityController, animated: true)
        }
    }
}
