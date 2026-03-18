import SwiftUI

struct HeatmapView: View {
    let dailyLogs: [DailyLog]
    
    // Config
    private let columns = 7
    private let rows = 12
    private let spacing: CGFloat = 4
    
    // Generate dates for the heatmap (last ~84 days depending on columns/rows)
    private var heatmapData: [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let totalDays = columns * rows
        
        // Etkileşimli olması için Pazar gününden bitecek şekilde de hizalayabiliriz.
        // Ama basitçe "Son X gün" yapacağız.
        
        var days: [HeatmapDay] = []
        for i in 0..<totalDays {
            // Geriye doğru gidelim ve ters çevirelim, böylece en son gün sağ altta olur
            let offset = (totalDays - 1) - i
            if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                let dateString = DateHelper.string(from: date)
                
                let count = dailyLogs.first(where: { $0.dateString == dateString })?.totalZikirs ?? 0
                days.append(HeatmapDay(date: date, count: count))
            }
        }
        return days
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(heatmapData) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorFor(count: day.count))
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            
            // Legend
            HStack {
                Text("Az")
                    .font(.caption2)
                    .foregroundColor(.themeSecondaryText)
                
                HStack(spacing: spacing) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.themeSecondaryText.opacity(0.1)).frame(width: 12, height: 12)
                    RoundedRectangle(cornerRadius: 2).fill(Color.themeAccent.opacity(0.3)).frame(width: 12, height: 12)
                    RoundedRectangle(cornerRadius: 2).fill(Color.themeAccent.opacity(0.6)).frame(width: 12, height: 12)
                    RoundedRectangle(cornerRadius: 2).fill(Color.themeAccent.opacity(1.0)).frame(width: 12, height: 12)
                }
                
                Text("Çok")
                    .font(.caption2)
                    .foregroundColor(.themeSecondaryText)
            }
            .padding(.top, 4)
        }
    }
    
    // GitHub-style coloring logic
    private func colorFor(count: Int) -> Color {
        if count == 0 {
            return Color.themeSecondaryText.opacity(0.1)
        } else if count < 50 {
            return Color.themeAccent.opacity(0.3)
        } else if count < 200 {
            return Color.themeAccent.opacity(0.6)
        } else {
            return Color.themeAccent.opacity(1.0)
        }
    }
}

struct HeatmapDay: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
