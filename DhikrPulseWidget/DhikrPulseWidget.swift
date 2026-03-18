import WidgetKit
import SwiftUI
import AppIntents

// MARK: - App Intent for Interactivity
@available(iOS 17.0, *)
struct IncrementDhikrIntent: AppIntent {
    static var title: LocalizedStringResource = "Zikri Artır"
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.cagriozay.DhikrPulse")
        let count = defaults?.integer(forKey: "widget_dhikr_count") ?? 0
        defaults?.set(count + 1, forKey: "widget_dhikr_count")
        
        // Bu artışı ana uygulamanın da bilmesi gerekir, "widget_unprocessed_clicks" gibi bir key yapabiliriz
        let unprocessed = defaults?.integer(forKey: "widget_unprocessed_clicks") ?? 0
        defaults?.set(unprocessed + 1, forKey: "widget_unprocessed_clicks")
        
        return .result()
    }
}

// MARK: - Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DhikrEntry {
        DhikrEntry(date: Date(), name: "Sübhanallah", count: 12, target: 33)
    }

    func getSnapshot(in context: Context, completion: @escaping (DhikrEntry) -> ()) {
        let entry = getEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntry()
        let timeline = Timeline(entries: [entry], policy: .never) // Only updates when app tells it to
        completion(timeline)
    }
    
    private func getEntry() -> DhikrEntry {
        let defaults = UserDefaults(suiteName: "group.com.cagriozay.DhikrPulse")
        let name = defaults?.string(forKey: "widget_dhikr_name") ?? "DhikrPulse"
        let count = defaults?.integer(forKey: "widget_dhikr_count") ?? 0
        let target = defaults?.integer(forKey: "widget_dhikr_target") ?? 33
        return DhikrEntry(date: Date(), name: name, count: count, target: target)
    }
}

struct DhikrEntry: TimelineEntry {
    let date: Date
    let name: String
    let count: Int
    let target: Int
}

// MARK: - Widget View
struct DhikrPulseWidgetEntryView : View {
    var entry: Provider.Entry

    var progress: Double {
        if entry.target == 0 { return 0 }
        return min(Double(entry.count) / Double(entry.target), 1.0)
    }
    
    var themeAccent: Color {
        // Fallback to green
        Color(red: 0.12, green: 0.84, blue: 0.45)
    }
    
    var themeBackground: Color {
        Color(red: 0.04, green: 0.09, blue: 0.07)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(entry.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 10)
                
                // Progress
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(themeAccent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)
                
                VStack(spacing: 0) {
                    Text("\(entry.count)")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                    
                    Text("/\(entry.target)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if #available(iOS 17.0, *) {
                // Interaktif Buton
                Button(intent: IncrementDhikrIntent()) {
                    Text("DOKUN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(themeBackground)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(themeAccent)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            } else {
                Text("DOKUN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(themeBackground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(themeAccent)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(themeBackground)
    }
}

// MARK: - Widget Definition
struct DhikrPulseWidget: Widget {
    let kind: String = "DhikrPulseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DhikrPulseWidgetEntryView(entry: entry)
                    .containerBackground(Color(red: 0.04, green: 0.09, blue: 0.07), for: .widget)
            } else {
                DhikrPulseWidgetEntryView(entry: entry)
                    .background(Color(red: 0.04, green: 0.09, blue: 0.07))
            }
        }
        .configurationDisplayName("DhikrPulse Sayaç")
        .description("Aktif zikrinizi ana ekranınızdan takip edin ve artırın.")
        .supportedFamilies([.systemSmall])
    }
}
