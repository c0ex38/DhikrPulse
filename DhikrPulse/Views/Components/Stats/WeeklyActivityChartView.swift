import SwiftUI

struct WeeklyActivityChartView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    private var todayStart: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
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
    
    private var weeklyTotal: Int {
        weeklyData.reduce(0) { $0 + $1.count }
    }
    
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
    
    private var maxWeeklyCount: Int {
        max(weeklyData.map { $0.count }.max() ?? 1, 1)
    }

    var body: some View {
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
    }
}
