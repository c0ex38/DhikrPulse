import SwiftUI

// MARK: - Dairesel İkon Butonu (CircleIconButton)
// CounterView, InsightsStatsView ve SettingsGoalsView'da tekrar eden yapı
struct CircleIconButton: View {
    let icon: String
    var size: CGFloat = 44
    var iconColor: Color = .themeAccent
    var backgroundColor: Color = .themeCard
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                )
        }
    }
}

// MARK: - Köşeli İkon Kutusu (IconBox)
// SettingsGoalsView PreferenceRow ve DhikrProgressCard'da tekrar eden yapı
struct IconBox: View {
    let icon: String
    var size: CGFloat = 44
    var cornerRadius: CGFloat = 10
    var iconColor: Color = .themeAccent
    var backgroundColor: Color = .themeBackground
    var iconSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .frame(width: size, height: size)
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: iconSize))
        }
    }
}

// MARK: - Bölüm Başlığı (SectionHeader)
// DhikrListView, SettingsGoalsView ve InsightsStatsView'da tekrar eden yapı
struct SectionHeader: View {
    let icon: String
    let title: String
    var iconColor: Color = .themeAccent
    var trailing: String? = nil
    var trailingAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.themeSecondaryText)
                .tracking(1)
            
            Spacer()
            
            if let trailing = trailing, let action = trailingAction {
                Button(trailing, action: action)
                    .font(.subheadline)
                    .foregroundColor(.themeAccent)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Kart Sarmalayıcı (ThemedCard)
// Her yerde .padding().background(Color.themeCard).cornerRadius(16) tekrar ediyor
struct ThemedCard<Content: View>: View {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 16
    var horizontalPadding: Bool = true
    
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding(padding)
            .background(Color.themeCard)
            .cornerRadius(cornerRadius)
            .if(horizontalPadding) { view in
                view.padding(.horizontal)
            }
    }
}

// MARK: - İlerleme Çubuğu (ProgressBarView)
// DhikrListView'da ince ve kalın olarak 2 kere kullanılıyor
struct ProgressBarView: View {
    let progress: Double
    var height: CGFloat = 4
    var trackColor: Color = .themeBackground
    var fillColor: Color = .themeAccent
    var hasShadow: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor.opacity(height > 4 ? 0.5 : 1.0))
                    .frame(height: height)
                
                Capsule()
                    .fill(fillColor)
                    .frame(width: max(0, geometry.size.width * min(progress, 1.0)), height: height)
                    .shadow(color: hasShadow ? fillColor.opacity(0.5) : .clear, radius: hasShadow ? 2 : 0)
                    .animation(.spring(), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Adaptive NavigationStack Stili (AdaptiveNavModifier)
// Tüm sayfaların NavigationStack'inde tekrar eden modifier zinciri
struct AdaptiveNavModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color.themeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func darkNavStyle() -> some View {
        self.modifier(AdaptiveNavModifier())
    }
}

// MARK: - Press Events Extension
// CounterView'dan taşındı - tüm uygulama genelinde kullanılabilir
extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    onPress()
                })
                .onEnded({ _ in
                    onRelease()
                })
        )
    }
}

// MARK: - Conditional View Modifier
// ThemedCard için gerekli yardımcı
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Tercih Satırı (PreferenceRow)
// SettingsGoalsView'dan buraya taşındı — Toggle ile birlikte bir ayar satırı
struct PreferenceRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            IconBox(icon: icon)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.themePrimaryText)
                    .font(.body)
                Text(subtitle)
                    .foregroundColor(.themeSecondaryText)
                    .font(.caption)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.themeAccent)
                .padding(.trailing, 16)
        }
        .padding(.vertical, 12)
        .padding(.leading, 12)
    }
}

// MARK: - Zikir İlerleme Kartı (DhikrProgressCard)
// DhikrListView'dan buraya taşındı — Kütüphane sayfasındaki her zikir satırı
struct DhikrProgressCard: View {
    let dhikr: DhikrItem
    var isActive: Bool = false
    
    private var isCompleted: Bool {
        dhikr.currentCount >= dhikr.targetCount && dhikr.targetCount > 0
    }
    
    private var progress: Double {
        guard dhikr.targetCount > 0 else { return 0 }
        return min(Double(dhikr.currentCount) / Double(dhikr.targetCount), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                IconBox(
                    icon: isCompleted ? "checkmark.circle.fill" : "sun.max.fill",
                    iconColor: isCompleted ? .themeAccent : .themeAccent.opacity(0.8)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(dhikr.name)
                        .font(.headline)
                        .foregroundColor(.themePrimaryText)
                }
                
                Spacer()
                
                Text(isCompleted ? "Tamamlandı" : "Günlük")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isCompleted ? Color.themeAccent.opacity(0.2) : Color.themeCard.opacity(0.5))
                    .foregroundColor(isCompleted ? .themeAccent : .themeSecondaryText)
                    .cornerRadius(6)
            }
            
            HStack {
                Text("İLERLEME")
                    .font(.caption2)
                    .foregroundColor(.themeSecondaryText)
                    .tracking(1)
                
                Spacer()
                
                Text("\(dhikr.currentCount) / \(dhikr.targetCount)")
                    .font(.caption.bold())
                    .foregroundColor(.themePrimaryText)
            }
            .padding(.top, 4)
            
            ProgressBarView(progress: progress, height: 4, hasShadow: true)
        }
        .padding(16)
        .background(isActive ? Color.themeAccent.opacity(0.1) : Color.themeCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.themeAccent : (isCompleted ? Color.themeAccent.opacity(0.5) : Color.clear), lineWidth: 1)
        )
    }
}

// MARK: - Tarih Yardımcısı (DateHelper)
// "yyyy-MM-dd" formatı uygulama genelinde çok sık tekrar ediyor
enum DateHelper {
    /// Paylaşımlı DateFormatter — her çağrıda yeniden yaratılmasını önler
    static let dayFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
    
    /// Bugünün tarihini "yyyy-MM-dd" string olarak döndürür
    static var todayString: String {
        dayFormatter.string(from: Date())
    }
    
    /// Verilen Date'i "yyyy-MM-dd" string'e çevirir
    static func string(from date: Date) -> String {
        dayFormatter.string(from: date)
    }
    
    /// Türkçe kısa tarih (ör: "3 Mar") formatı
    static let shortDateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "tr_TR")
        fmt.dateFormat = "d MMM"
        return fmt
    }()
}
