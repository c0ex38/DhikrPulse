import SwiftUI

struct ReminderSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("daily_reminder_enabled") private var isReminderEnabled = false
    @AppStorage("daily_reminder_hour") private var reminderHour = 20
    @AppStorage("daily_reminder_minute") private var reminderMinute = 0
    
    // Binding for DatePicker
    private var reminderTime: Binding<Date> {
        Binding<Date>(
            get: {
                let calendar = Calendar.current
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return calendar.date(from: components) ?? Date()
            },
            set: { newDate in
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 20
                reminderMinute = components.minute ?? 0
                
                // Reschedule if enabled
                if isReminderEnabled {
                    scheduleReminder()
                }
            }
        )
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
                
                // Toggle Switch
                Toggle(isOn: Binding(
                    get: { isReminderEnabled },
                    set: { newValue in
                        isReminderEnabled = newValue
                        if newValue {
                            // Check permission first
                            notificationManager.requestAuthorization()
                            scheduleReminder()
                        } else {
                            // Cancel all
                            notificationManager.cancelAllReminders()
                        }
                    }
                )) {
                    Text("Günlük Hatırlatıcı")
                        .foregroundColor(.white)
                }
                .tint(Color(red: 0.12, green: 0.84, blue: 0.45))
                .padding(.horizontal)
                
                // Active State Content
                if isReminderEnabled {
                    VStack {
                        Divider().background(Color.white.opacity(0.1))
                        
                        DatePicker("Hatırlatma Saati", selection: reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
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
    }
    
    private func scheduleReminder() {
        notificationManager.cancelAllReminders() // Clear previous
        
        let messages = [
            "Günün zikir hedefini tamamladın mı?",
            "Kalpler ancak Allah'ı anmakla huzur bulur.",
            "Biraz vakit ayırıp zikir çekmeye ne dersin?",
            "Manevi huzur için DhikrPulse'a uğra."
        ]
        
        let randomMessage = messages.randomElement() ?? messages[0]
        
        notificationManager.scheduleDailyReminder(
            id: "daily_dhikr_reminder",
            title: "DhikrPulse Vakti 🌙",
            body: randomMessage,
            hour: reminderHour,
            minute: reminderMinute
        )
    }
}
