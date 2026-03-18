import SwiftUI

struct ProAnalyticsChartView: View {
    let dhikrs: [DhikrItem]
    
    // Yalnızca count'u 0'dan büyük olanları filtrele
    private var activeDhikrs: [DhikrItem] {
        dhikrs.filter { $0.currentCount > 0 }.sorted(by: { $0.currentCount > $1.currentCount })
    }
    
    private var totalCount: Int {
        activeDhikrs.reduce(0) { $0 + $1.currentCount }
    }
    
    // Renk paleti (Dinamik)
    private let colors: [Color] = [
        .themeAccent,
        .blue,
        .purple,
        .orange,
        .yellow,
        .pink,
        .cyan
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            if activeDhikrs.isEmpty {
                Text("Henüz istatistik üretecek kadar zikir kaydı yok.")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                HStack(spacing: 24) {
                    // Donut Chart
                    ZStack {
                        // Background circle for empty state or base
                        Circle()
                            .stroke(Color.themeSecondaryText.opacity(0.1), lineWidth: 20)
                            .frame(width: 140, height: 140)
                        
                        // Segments
                        ForEach(0..<activeDhikrs.count, id: \.self) { index in
                            DonutSegment(
                                startAngle: startAngle(for: index),
                                endAngle: endAngle(for: index),
                                color: colors[index % colors.count]
                            )
                        }
                        
                        // Center Info
                        VStack(spacing: 4) {
                            Text("Toplam")
                                .font(.caption2)
                                .foregroundColor(.themeSecondaryText)
                            Text("\(totalCount)")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                        }
                    }
                    .frame(width: 140, height: 140)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(0..<min(activeDhikrs.count, 5), id: \.self) { index in
                            let item = activeDhikrs[index]
                            let percentage = totalCount > 0 ? Double(item.currentCount) / Double(totalCount) * 100 : 0
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(colors[index % colors.count])
                                    .frame(width: 10, height: 10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    
                                    Text(String(format: "%.1f%% (%d)", percentage, item.currentCount))
                                        .font(.system(size: 9))
                                        .foregroundColor(.themeSecondaryText)
                                }
                            }
                        }
                        
                        if activeDhikrs.count > 5 {
                            Text("+ \(activeDhikrs.count - 5) daha")
                                .font(.caption2)
                                .foregroundColor(.themeSecondaryText)
                                .padding(.leading, 18)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Angle Calculations for Custom Donut Chart
    
    private func startAngle(for index: Int) -> Angle {
        if index == 0 { return .degrees(-90) }
        
        var totalBefore: Int = 0
        for i in 0..<index {
            totalBefore += activeDhikrs[i].currentCount
        }
        
        let percentage = Double(totalBefore) / Double(totalCount)
        return .degrees(-90 + (percentage * 360))
    }
    
    private func endAngle(for index: Int) -> Angle {
        var totalIncluding: Int = 0
        for i in 0...index {
            totalIncluding += activeDhikrs[i].currentCount
        }
        
        let percentage = Double(totalIncluding) / Double(totalCount)
        return .degrees(-90 + (percentage * 360))
    }
}

// MARK: - Individual Donut Segment Component
struct DonutSegment: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    
    @State private var animateEnd: Angle = .degrees(-90)
    
    var body: some View {
        Path { path in
            path.addArc(
                center: CGPoint(x: 70, y: 70), // Half of 140
                radius: 70,
                startAngle: startAngle,
                endAngle: animateEnd,
                clockwise: false
            )
        }
        .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .butt)) // butt cap for seamless donut
        .animation(.easeOut(duration: 1.0).delay(0.2), value: animateEnd)
        .onAppear {
            animateEnd = endAngle
        }
    }
}
