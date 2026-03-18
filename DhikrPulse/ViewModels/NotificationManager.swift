import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    // MARK: - İzin Yönetimi
    
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                completion?(granted)
                if let error = error {
                    print("Bildirim izni istenirken hata oluştu: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Kullanıcıyı sistem Ayarlar > Bildirimler ekranına yönlendirir
    func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Çoklu Hatırlatıcı Planlama
    
    /// Mesaj rotasyonu ile 7 gün ileriye günlük hatırlatıcı planlar
    private let messages = [
        "Günün zikir hedefini tamamladın mı?",
        "Kalpler ancak Allah'ı anmakla huzur bulur.",
        "Biraz vakit ayırıp zikir çekmeye ne dersin?",
        "Manevi huzur için DhikrPulse'a uğra.",
        "Zikir, kalbin gıdasıdır. Bugün besledin mi?",
        "Her gün bir adım daha. Serini kırma! 🔥",
        "Ruhunu dinlendir, zikrini çek. 🌙"
    ]
    
    /// Belirli bir saat için 7 günlük rotasyonlu bildirim planlar
    func scheduleRotatingReminders(hour: Int, minute: Int, reminderId: String) {
        // Bu saat için önceki bildirimleri temizle
        cancelRemindersForId(reminderId)
        
        let calendar = Calendar.current
        let today = Date()
        
        for dayOffset in 0..<7 {
            guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = "DhikrPulse Vakti 🌙"
            content.body = messages[dayOffset % messages.count]
            content.sound = .default
            content.badge = 1
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let requestId = "\(reminderId)_day\(dayOffset)"
            let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Bildirim eklenirken hata: \(error.localizedDescription)")
                }
            }
        }
        
        // 7 günden sonra tekrar planlanması için kalıcı bir tekrar eden bildirim de ekle
        scheduleRepeatingFallback(hour: hour, minute: minute, reminderId: reminderId)
        
        print("7 günlük rotasyonlu bildirimler planlandı: \(hour):\(String(format: "%02d", minute)) — ID: \(reminderId)")
    }
    
    /// 7 günlük rotasyon bittikten sonra devam eden yedek (fallback) tekrar eden bildirim
    private func scheduleRepeatingFallback(hour: Int, minute: Int, reminderId: String) {
        let content = UNMutableNotificationContent()
        content.title = "DhikrPulse Vakti 🌙"
        content.body = messages.randomElement() ?? messages[0]
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "\(reminderId)_repeating", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Belirli bir ID prefix'ine ait tüm bildirimleri iptal eder
    func cancelRemindersForId(_ reminderId: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .filter { $0.identifier.hasPrefix(reminderId) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
            print("Bildirimler iptal edildi (\(idsToRemove.count) adet): \(reminderId)")
        }
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Tüm bildirimler iptal edildi")
    }
    
    // MARK: - Badge Yönetimi
    
    func clearBadge() {
        if #available(iOS 17.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0)
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
    
    // MARK: - Test Bildirimi
    
    func scheduleTestNotification(seconds: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = "DhikrPulse"
        content.body = "Bu bir test bildirimidir 🌙"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Test bildirimi oluşturulamadı: \(error)")
            } else {
                print("Test bildirimi \(seconds) saniyeye planlandı.")
            }
        }
    }
}
