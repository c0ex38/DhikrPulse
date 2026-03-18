import SwiftUI

struct InsightsStatsView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    @EnvironmentObject private var storeManager: StoreManager
    
    // MARK: - Hesaplamalar
    
    /// Bugünün başlangıç tarihi
    private var todayStart: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    /// Bugünkü toplam zikir
    private var totalToday: Int {
        let dateString = DateHelper.todayString
        return viewModel.dailyLogs.first(where: { $0.dateString == dateString })?.totalZikirs ?? 0
    }
    
    /// Dünkü toplam zikir
    private var totalYesterday: Int {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
        let dateString = DateHelper.string(from: yesterday)
        return viewModel.dailyLogs.first(where: { $0.dateString == dateString })?.totalZikirs ?? 0
    }
    
    /// Düne göre yüzde değişim
    private var changePercent: Int {
        guard totalYesterday > 0 else {
            return totalToday > 0 ? 100 : 0
        }
        return Int((Double(totalToday - totalYesterday) / Double(totalYesterday)) * 100)
    }
    
    /// En çok okunan zikir (tüm zamanlar)
    private var mostFrequentDhikr: DhikrItem? {
        viewModel.dhikrs.sorted { $0.currentCount > $1.currentCount }.first
    }
    
    /// Son 7 gün için günlük veriler (Pazartesi'den Pazar'a)
    private var weeklyData: [(day: String, count: Int, isToday: Bool)] {
        let calendar = Calendar.current
        let today = todayStart
        let dayNames = ["PZT", "SAL", "ÇAR", "PER", "CUM", "CTS", "PAZ"]
        
        // Haftanın başlangıcını bul (Pazartesi)
        let weekday = calendar.component(.weekday, from: today)
        // weekday: 1=Pazar, 2=Pazartesi...
        let daysFromMonday = (weekday + 5) % 7 // 0=Pazartesi, 6=Pazar
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return dayNames.map { ($0, 0, false) }
        }
        
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: monday)!
            let dateString = DateHelper.string(from: date)
            
            let count = viewModel.dailyLogs.first(where: { $0.dateString == dateString })?.totalZikirs ?? 0
            let isToday = calendar.isDate(date, inSameDayAs: today)
            return (dayNames[offset], count, isToday)
        }
    }
    
    /// Haftalık toplam
    private var weeklyTotal: Int {
        weeklyData.reduce(0) { $0 + $1.count }
    }
    
    /// Haftalık tarih aralığı metni
    private var weeklyDateRange: String {
        let calendar = Calendar.current
        let today = todayStart
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today),
              let sunday = calendar.date(byAdding: .day, value: 6, to: monday) else {
            return ""
        }
        return "\(DateHelper.shortDateFormatter.string(from: monday)) - \(DateHelper.shortDateFormatter.string(from: sunday))"
    }
    
    /// Mevcut seri (art arda kaç gün en az 1 zikir yapılmış)
    private var currentStreak: Int {
        viewModel.userProfile?.currentStreak ?? 0
    }
    
    /// Sonraki başarım seviyeleri
    private var nextMilestone: Int {
        let milestones = [3, 7, 14, 21, 30, 60, 90, 180, 365]
        return milestones.first(where: { $0 > currentStreak }) ?? (currentStreak + 30)
    }
    
    /// Streak ilerleme yüzdesi (sonraki başarıma göre)
    private var streakProgress: Double {
        guard nextMilestone > 0 else { return 0 }
        return min(Double(currentStreak) / Double(nextMilestone), 1.0)
    }
    
    // MARK: - Grafik yükseklik hesabı
    private var maxWeeklyCount: Int {
        max(weeklyData.map { $0.count }.max() ?? 1, 1)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Üst Özet Kartları
                        HStack(spacing: 16) {
                            // Bugün Toplam Kartı
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader(icon: "bolt.fill", title: "BUGÜN TOPLAM")
                                    .padding(.horizontal, -16) // SectionHeader kendi padding ekliyor
                                
                                Text("\(totalToday)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                                
                                if totalYesterday > 0 || totalToday > 0 {
                                    HStack(spacing: 4) {
                                        Image(systemName: changePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                                            .font(.caption2.bold())
                                        Text("%\(abs(changePercent))")
                                            .font(.caption.bold())
                                        Text("düne göre")
                                            .font(.caption)
                                    }
                                    .foregroundColor(changePercent >= 0 ? .themeAccent : .orange)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.themeCard)
                            .cornerRadius(16)
                            
                            // En Çok Okunan Kartı
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                    Text("EN ÇOK OKUNAN")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.themeSecondaryText)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                
                                Text(mostFrequentDhikr?.name ?? "Henüz yok")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text("\(mostFrequentDhikr?.currentCount ?? 0) adet")
                                    .font(.subheadline)
                                    .foregroundColor(.yellow)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.themeCard)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Haftalık Grafik Kartı
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Haftalık Aktivite")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(weeklyDateRange)
                                        .font(.caption)
                                        .foregroundColor(.themeSecondaryText)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("\(weeklyTotal)")
                                        .font(.title3.bold())
                                        .foregroundColor(.themeAccent)
                                    Text("TOPLAM ZİKİR")
                                        .font(.caption2.bold())
                                        .foregroundColor(.themeSecondaryText)
                                        .tracking(1)
                                }
                            }
                            
                            // Gerçek Verili Grafik
                            HStack(alignment: .bottom, spacing: 0) {
                                ForEach(weeklyData, id: \.day) { item in
                                    VStack(spacing: 8) {
                                        // Sayı etiketi (0 değilse göster)
                                        if item.count > 0 {
                                            Text("\(item.count)")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(item.isToday ? .themeAccent : .themeSecondaryText)
                                        }
                                        
                                        // Bar
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(item.isToday ? Color.themeAccent : (item.count > 0 ? Color.themeAccent.opacity(0.4) : Color.themeSecondaryText.opacity(0.15)))
                                            .frame(width: 8, height: max(4, CGFloat(item.count) / CGFloat(maxWeeklyCount) * 120))
                                            .animation(.spring(response: 0.6), value: item.count)
                                        
                                        // Gün Etiketi
                                        Text(item.day)
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(item.isToday ? .white : .themeSecondaryText)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 160)
                            .padding(.top, 10)
                        }
                        .padding()
                        .background(Color.themeCard)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // MARK: - Başarımlar (Gamification)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Başarımlarınız")
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
                        
                        // MARK: - Seri (Streak) Kartı
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mevcut Seri (Streak)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
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
                                        .foregroundColor(.white)
                                    
                                    if currentStreak > 0 {
                                        Text("Sonraki başarım (\(nextMilestone) gün) için \(nextMilestone - currentStreak) gün kaldı")
                                            .font(.caption)
                                            .foregroundColor(.themeSecondaryText)
                                    } else {
                                        Text("Bugün başla ve serini oluştur!")
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
                        
                        // MARK: - Zikir Dağılımı (Pro Analytics)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Gelişmiş Zikir Dağılımı")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                if !storeManager.isPro {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.themeSecondaryText)
                                }
                            }
                            
                            if storeManager.isPro {
                                ProAnalyticsChartView(dhikrs: viewModel.dhikrs)
                            } else {
                                ZStack {
                                    ProAnalyticsChartView(dhikrs: viewModel.dhikrs)
                                        .blur(radius: 6)
                                        .opacity(0.5)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "chart.pie.fill")
                                            .font(.title)
                                            .foregroundColor(.yellow)
                                        Text("Detaylı dağılım grafiğini görmek için Premium'a geçin")
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
                        
                        // MARK: - Zikir Isı Haritası (Heatmap) / Pro Only
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Aktivite Isı Haritası")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                if !storeManager.isPro {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.themeSecondaryText)
                                }
                            }
                            
                            if storeManager.isPro {
                                HeatmapView(dailyLogs: viewModel.dailyLogs)
                            } else {
                                ZStack {
                                    HeatmapView(dailyLogs: viewModel.dailyLogs) // Arka planda flu göster
                                        .blur(radius: 6)
                                        .opacity(0.5)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .font(.title)
                                            .foregroundColor(.yellow)
                                        Text("Geçmiş aktivite haritasını görmek için Premium'a geçin")
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
                        
                        // MARK: - Son Zikirler
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(
                                icon: "clock.arrow.circlepath",
                                title: "SON ZİKİRLER",
                                trailing: "Tümünü Gör"
                            ) { }
                            
                            if viewModel.dhikrs.isEmpty {
                                Text("Henüz zikir eklenmemiş")
                                    .font(.subheadline)
                                    .foregroundColor(.themeSecondaryText)
                                    .padding()
                            } else {
                                VStack(spacing: 1) {
                                    ForEach(viewModel.dhikrs.prefix(5)) { dhikr in
                                        let isCompleted = dhikr.currentCount >= dhikr.targetCount && dhikr.targetCount > 0
                                        HStack {
                                            IconBox(
                                                icon: isCompleted ? "checkmark.circle.fill" : "sparkles",
                                                size: 40,
                                                iconColor: isCompleted ? .themeAccent : .yellow,
                                                backgroundColor: .themeBackground
                                            )
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(dhikr.name)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.white)
                                                Text(relativeDate(from: dhikr.lastUpdated))
                                                    .font(.caption2)
                                                    .foregroundColor(.themeSecondaryText)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(dhikr.currentCount)/\(dhikr.targetCount)")
                                                .font(.headline.bold())
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                        .background(Color.themeCard)
                                    }
                                }
                                .cornerRadius(16)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("İstatistikler")
            .navigationBarTitleDisplayMode(.inline)
            .darkNavStyle()
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
    
    // MARK: - Yardımcı Fonksiyonlar
    private func relativeDate(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Bugün"
        } else if calendar.isDateInYesterday(date) {
            return "Dün"
        } else {
            return DateHelper.shortDateFormatter.string(from: date)
        }
    }
}

#Preview {
    InsightsStatsView()
        .environmentObject(DhikrViewModel())
}
