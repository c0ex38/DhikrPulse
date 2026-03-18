import SwiftUI

struct AchievementSectionView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("stats_achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Achievement.all) { achievement in
                        let isEarned = viewModel.earnedAchievements.contains(where: { $0.id == achievement.id })
                        
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isEarned ? Color.themeAccent.opacity(0.2) : Color.themeSecondaryText.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: achievement.icon)
                                    .font(.title2)
                                    .foregroundColor(isEarned ? .themeAccent : .themeSecondaryText.opacity(0.5))
                            }
                            
                            Text(achievement.name)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(isEarned ? .white : .themeSecondaryText)
                            
                            Text(achievement.description)
                                .font(.system(size: 9))
                                .foregroundColor(.themeSecondaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 80)
                        }
                        .opacity(isEarned ? 1.0 : 0.6)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, -16) // Edge-to-edge scroll
        }
        .padding()
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
