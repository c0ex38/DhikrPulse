import SwiftUI

struct StreakCardView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    // Mevcut seri
    private var currentStreak: Int {
        viewModel.userProfile?.currentStreak ?? 0
    }
    
    // Sonraki başarım seviyeleri
    private var nextMilestone: Int {
        let milestones = [3, 7, 14, 21, 30, 60, 90, 180, 365]
        return milestones.first(where: { $0 > currentStreak }) ?? (currentStreak + 30)
    }
    
    // Streak ilerleme yüzdesi (sonraki başarıma göre)
    private var streakProgress: Double {
        guard nextMilestone > 0 else { return 0 }
        return min(Double(currentStreak) / Double(nextMilestone), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("stats_current_streak")
                .font(.headline)
                .foregroundColor(.themePrimaryText)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.themeAccent.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    Circle()
                        .trim(from: 0, to: streakProgress)
                        .stroke(Color.themeAccent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(), value: streakProgress)
                    Image(systemName: "flame.fill")
                        .foregroundColor(.themeAccent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentStreak > 0 ? "\(currentStreak) Günlük Seri!" : "Henüz seri yok")
                        .font(.headline)
                        .foregroundColor(.themePrimaryText)
                    
                    if currentStreak > 0 {
                        Text(String(format: "stats_next_milestone", "\(nextMilestone)", "\(nextMilestone - currentStreak)"))
                            .font(.caption)
                            .foregroundColor(.themeSecondaryText)
                    } else {
                        Text("stats_streak_start")
                            .font(.caption)
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: currentStreak >= 7 ? "trophy.fill" : "flame")
                    .foregroundColor(currentStreak >= 7 ? .yellow : .themeSecondaryText)
                    .font(.title2)
            }
            .padding()
            .background(Color.themeBackground)
            .cornerRadius(12)
        }
        .padding()
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
