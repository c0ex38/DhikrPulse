import SwiftUI

struct TodaySummaryCardsView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    // MARK: - Hesaplamalar
    private var todayStart: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private var totalToday: Int {
        let dateString = DateHelper.todayString
        return viewModel.dailyLogs.first(where: { $0.dateString == dateString })?.totalZikirs ?? 0
    }
    
    private var totalYesterday: Int {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
        let dateString = DateHelper.string(from: yesterday)
        return viewModel.dailyLogs.first(where: { $0.dateString == dateString })?.totalZikirs ?? 0
    }
    
    private var changePercent: Int {
        guard totalYesterday > 0 else {
            return totalToday > 0 ? 100 : 0
        }
        return Int((Double(totalToday - totalYesterday) / Double(totalYesterday)) * 100)
    }
    
    private var mostFrequentDhikr: DhikrItem? {
        viewModel.dhikrs.sorted { $0.currentCount > $1.currentCount }.first
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Bugün Toplam Kartı
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(icon: "bolt.fill", title: "BUGÜN TOPLAM")
                    .padding(.horizontal, -16) // SectionHeader kendi padding ekliyor
                
                Text("\(totalToday)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.themePrimaryText)
                
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
                    .foregroundColor(.themePrimaryText)
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
    }
}
