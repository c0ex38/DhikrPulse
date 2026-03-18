import SwiftUI

/// Hatırlatıcı saatini tutan basit yapı (JSON encode/decode için Codable)
struct ReminderTime: Codable, Identifiable, Equatable {
    var id: String { "\(hour)_\(minute)" }
    var hour: Int
    var minute: Int
    
    var displayString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}

struct ReminderSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("daily_reminder_enabled") private var isReminderEnabled = false
    @AppStorage("reminder_times_json") private var reminderTimesJSON = "[]"
    
    @State private var showingTimePicker = false
    @State private var newReminderDate = Date()
    
    private var reminderTimes: [ReminderTime] {
        get {
            guard let data = reminderTimesJSON.data(using: .utf8),
                  let times = try? JSONDecoder().decode([ReminderTime].self, from: data) else {
                return []
            }
            return times.sorted { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
        }
    }
    
    private func saveReminderTimes(_ times: [ReminderTime]) {
        if let data = try? JSONEncoder().encode(times),
           let json = String(data: data, encoding: .utf8) {
            reminderTimesJSON = json
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Akıllı Hatırlatıcılar")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.themeCard)
            
            VStack(spacing: 16) {
                // Info text
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.themeSecondaryText)
                        .font(.title3)
                    
                    Text("Zikir hedeflerinizi unutmamak için günlük hatırlatıcı kurabilirsiniz.")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Bildirim İzni Reddedildi Uyarısı
                if isReminderEnabled && !notificationManager.isAuthorized {
                    permissionDeniedBanner
                }
                
                // Toggle Switch
                Toggle(isOn: Binding(
                    get: { isReminderEnabled },
                    set: { newValue in
                        isReminderEnabled = newValue
                        if newValue {
                            notificationManager.requestAuthorization { granted in
                                if granted {
                                    // Eğer hiç hatırlatıcı yoksa varsayılan 20:00 ekle
                                    if reminderTimes.isEmpty {
                                        addReminder(hour: 20, minute: 0)
                                    } else {
                                        rescheduleAll()
                                    }
                                }
                            }
                        } else {
                            notificationManager.cancelAllReminders()
                        }
                    }
                )) {
                    Text("Günlük Hatırlatıcı")
                        .foregroundColor(.white)
                }
                .tint(Color.themeAccent)
                .padding(.horizontal)
                
                // Active State: Hatırlatıcı Saatleri Listesi
                if isReminderEnabled && notificationManager.isAuthorized {
                    VStack(spacing: 12) {
                        Divider().background(Color.white.opacity(0.1))
                        
                        // Mevcut saatler
                        if !reminderTimes.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(reminderTimes) { time in
                                    reminderChip(time: time)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Yeni saat ekle butonu
                        Button {
                            showingTimePicker = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.body)
                                Text("Saat Ekle")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.themeAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.themeAccent.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 16)
            .background(Color.themeBackground)
        }
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            notificationManager.checkAuthorizationStatus()
        }
        .sheet(isPresented: $showingTimePicker) {
            timePickerSheet
        }
    }
    
    // MARK: - Sub-views
    
    /// Bildirim izni reddedildiğinde gösterilecek uyarı kutusu
    private var permissionDeniedBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Bildirim İzni Gerekli")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text("Hatırlatıcılar için bildirim izni vermeniz gerekiyor.")
                    .font(.caption2)
                    .foregroundColor(.themeSecondaryText)
            }
            
            Spacer()
            
            Button("Ayarlar") {
                notificationManager.openSystemSettings()
            }
            .font(.caption.bold())
            .foregroundColor(.themeBackground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange)
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    /// Hatırlatıcı saat chip'i (uzun basınca silme)
    private func reminderChip(time: ReminderTime) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.fill")
                .font(.caption2)
            Text(time.displayString)
                .font(.subheadline.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.themeAccent.opacity(0.2))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.themeAccent.opacity(0.4), lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) {
                removeReminder(time: time)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
    
    /// Yeni saat seçmek için sheet
    private var timePickerSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Hatırlatma Saati Seçin")
                    .font(.headline)
                    .foregroundColor(.white)
                
                DatePicker("", selection: $newReminderDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                Spacer()
            }
            .padding(.top, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.themeBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        showingTimePicker = false
                    }
                    .foregroundColor(.themeSecondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ekle") {
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: newReminderDate)
                        let hour = components.hour ?? 20
                        let minute = components.minute ?? 0
                        addReminder(hour: hour, minute: minute)
                        showingTimePicker = false
                    }
                    .foregroundColor(.themeAccent)
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Hatırlatıcı Yönetimi
    
    private func addReminder(hour: Int, minute: Int) {
        var times = reminderTimes
        let newTime = ReminderTime(hour: hour, minute: minute)
        
        // Aynı saat zaten varsa ekleme
        guard !times.contains(where: { $0.hour == hour && $0.minute == minute }) else { return }
        
        times.append(newTime)
        saveReminderTimes(times)
        
        // Bildirimi planla
        notificationManager.scheduleRotatingReminders(
            hour: hour,
            minute: minute,
            reminderId: "reminder_\(hour)_\(minute)"
        )
    }
    
    private func removeReminder(time: ReminderTime) {
        var times = reminderTimes
        times.removeAll { $0.id == time.id }
        saveReminderTimes(times)
        
        // Bilirimi iptal et
        notificationManager.cancelRemindersForId("reminder_\(time.hour)_\(time.minute)")
    }
    
    private func rescheduleAll() {
        notificationManager.cancelAllReminders()
        for time in reminderTimes {
            notificationManager.scheduleRotatingReminders(
                hour: time.hour,
                minute: time.minute,
                reminderId: "reminder_\(time.hour)_\(time.minute)"
            )
        }
    }
}

// MARK: - FlowLayout (Chip'ler için yatay akışlı layout)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }
        
        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
