import SwiftUI

struct InsightsStatsView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.themeBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Görünüm Seç", selection: $selectedTab) {
                        Text("Kişisel").tag(0)
                        Text("Küresel").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if selectedTab == 0 {
                        ScrollView {
                            VStack(spacing: 24) {
                                // Üst Özet Kartları
                                TodaySummaryCardsView()
                                
                                // Haftalık Grafik Kartı
                                WeeklyActivityChartView()
                                
                                // Başarımlar (Gamification)
                                AchievementSectionView()
                                
                                // Seri (Streak) Kartı
                                StreakCardView()
                                
                                // Zikir Dağılımı (Pro Analytics)
                                PremiumFeatureSectionView(
                                    title: "Gelişmiş Zikir Dağılımı",
                                    icon: "chart.pie.fill",
                                    message: "Detaylı dağılım grafiğini görmek için Premium'a geçin"
                                ) {
                                    ProAnalyticsChartView(dhikrs: viewModel.dhikrs)
                                }
                                
                                // Zikir Isı Haritası (Heatmap) / Pro Only
                                PremiumFeatureSectionView(
                                    title: "Aktivite Isı Haritası",
                                    icon: "star.fill",
                                    message: "Geçmiş aktivite haritasını görmek için Premium'a geçin"
                                ) {
                                    HeatmapView(dailyLogs: viewModel.dailyLogs)
                                }
                                
                                // Son Zikirler
                                RecentDhikrsListView()
                            }
                            .padding(.vertical, 20)
                            .padding(.bottom, 60)
                        }
                    } else {
                        LeaderboardView()
                    }
                }
            }
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// A generic wrapper for premium sections
struct PremiumFeatureSectionView<Content: View>: View {
    @EnvironmentObject private var storeManager: StoreManager
    var title: String
    var icon: String
    var message: String
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if !storeManager.isPro {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.themeSecondaryText)
                }
            }
            
            if storeManager.isPro {
                content
            } else {
                ZStack {
                    content
                        .blur(radius: 6)
                        .opacity(0.5)
                    
                    VStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundColor(.yellow)
                        Text(message)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                    }
                }
            }
        }
        .padding()
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    InsightsStatsView()
        .environmentObject(DhikrViewModel())
}

