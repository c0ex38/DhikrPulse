import SwiftUI

struct RecentDhikrsListView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    var body: some View {
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
                                    .foregroundColor(.themePrimaryText)
                                Text(relativeDate(from: dhikr.lastUpdated))
                                    .font(.caption2)
                                    .foregroundColor(.themeSecondaryText)
                            }
                            
                            Spacer()
                            
                            Text("\(dhikr.currentCount)/\(dhikr.targetCount)")
                                .font(.headline.bold())
                                .foregroundColor(.themePrimaryText)
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
