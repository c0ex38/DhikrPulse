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
                                .foregroundColor(.themePrimaryText)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("pro_upgrade_title")
                                .font(.headline)
                                .foregroundColor(.themePrimaryText)
                            Text("pro_upgrade_desc")
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
                        title: "manage_subs",
                        subtitle: "manage_subs_desc",
                        trailing: .externalLink
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}
