import SwiftUI

struct UserProfileHeaderView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    @Binding var editedName: String
    @Binding var showingNameEditAlert: Bool
    
    private var totalLifetimeZikirs: Int {
        viewModel.dailyLogs.reduce(0) { $0 + $1.totalZikirs }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar & Name
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.themeAccent, Color.themeAccent.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(Color.themeBackground)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(viewModel.userProfile?.displayName ?? "Anonim Hesap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Edit Icon Button
                        Button {
                            editedName = viewModel.userProfile?.displayName ?? ""
                            showingNameEditAlert = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.themeSecondaryText)
                                .padding(4)
                                .background(Color.themeBackground)
                                .clipShape(Circle())
                        }
                        
                        if storeManager.isPro {
                            Text("PRO")
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(storeManager.isPro ? "Premium Üye" : "Ücretsiz Hesap")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                }
                
                Spacer()
            }
            
            // Mini Stats Row
            HStack(spacing: 0) {
                // Streak
                miniStatItem(
                    icon: "flame.fill",
                    value: "\(viewModel.userProfile?.currentStreak ?? 0)",
                    label: "Günlük Seri",
                    iconColor: .orange
                )
                
                miniDivider
                
                // Total Zikirs
                miniStatItem(
                    icon: "heart.fill",
                    value: totalLifetimeZikirs > 999 ? "\(totalLifetimeZikirs / 1000)K" : "\(totalLifetimeZikirs)",
                    label: "Toplam Zikir",
                    iconColor: .red
                )
                
                miniDivider
                
                // Max Streak
                miniStatItem(
                    icon: "trophy.fill",
                    value: "\(viewModel.userProfile?.maxStreak ?? 0)",
                    label: "En İyi Seri",
                    iconColor: .yellow
                )
            }
            .padding(.vertical, 12)
            .background(Color.themeBackground)
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private func miniStatItem(icon: String, value: String, label: String, iconColor: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.themeSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var miniDivider: some View {
        Rectangle()
            .fill(Color.themeSecondaryText.opacity(0.2))
            .frame(width: 1, height: 40)
    }
}
