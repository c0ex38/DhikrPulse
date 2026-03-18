import Foundation
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

class DhikrViewModel: ObservableObject {
    @Published var dhikrs: [DhikrItem] = []
    @Published var dailyLogs: [DailyLog] = []
    @Published var categories: [DhikrCategory] = []
    @Published var userProfile: UserProfile?
    @Published var currentUserId: String?
    
    // Error Handling
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // Toplam yaşam boyu zikir sayısı
    var totalLifetimeZikirs: Int {
        dailyLogs.reduce(0) { $0 + $1.totalZikirs }
    }
    
    // Kazanılan başarımları hesapla
    var earnedAchievements: [Achievement] {
        let total = totalLifetimeZikirs
        let maxStreak = userProfile?.maxStreak ?? 0
        let currentStreak = userProfile?.currentStreak ?? 0
        
        return Achievement.all.filter { achievement in
            if achievement.requiredTotal > 0 {
                return total >= achievement.requiredTotal
            } else if achievement.requiredStreak > 0 {
                return maxStreak >= achievement.requiredStreak || currentStreak >= achievement.requiredStreak
            }
            return false
        }
    }
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var firestoreListenerCancellables = [ListenerRegistration]()
    
    init() {
        setupAuthListener()
    }
    
    // MARK: - Auth
    private func setupAuthListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if let user = user {
                print("Signed in as UID: \(user.uid)")
                
                // Eğer farklı bir kullanıcıysa veya dinleyiciler boşsa dinleyicileri başlat
                if self.currentUserId != user.uid || self.firestoreListenerCancellables.isEmpty {
                    self.currentUserId = user.uid
                    self.setupListeners()
                }
            } else {
                print("User signed out or invalid token. Signing in anonymously again...")
                // Mevcut dinleyicileri temizle
                self.clearListeners()
                self.currentUserId = nil
                self.signInAnonymously()
            }
        }
    }
    
    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Giriş yapılamadı: \(error.localizedDescription)"
                    self.showError = true
                }
                print("Error signing in anonymously: \(error.localizedDescription)")
            }
        }
    }
    
    private func clearListeners() {
        for listener in firestoreListenerCancellables {
            listener.remove()
        }
        firestoreListenerCancellables.removeAll()
    }
    
    // MARK: - Helper: User Collection Reference
    private func userDocRef() -> DocumentReference? {
        guard let uid = currentUserId else { return nil }
        return db.collection("users").document(uid)
    }
    
    // MARK: - Firestore Listeners
    private func setupListeners() {
        clearListeners() // Öncekileri temizle garantilemek için
        guard let userRef = userDocRef() else { return }
        
        // Listen to User Profile
        let profileListener = userRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                return
            }
            guard let document = documentSnapshot, document.exists else {
                // Initialize default profile
                let defaultName = "user\(Int.random(in: 100000...999999))"
                let defaultProfile = UserProfile(displayName: defaultName)
                try? userRef.setData(from: defaultProfile, merge: true)
                return
            }
            
            var profile = try? document.data(as: UserProfile.self)
            
            // Eğer profil var ama isimsizse, ona varsayılan bir isim ata
            if profile != nil && (profile?.displayName == nil || profile?.displayName?.isEmpty == true) {
                let generatedName = "user\(Int.random(in: 100000...999999))"
                profile?.displayName = generatedName
                try? userRef.setData(from: profile, merge: true)
            }
            
            self.userProfile = profile
        }
        firestoreListenerCancellables.append(profileListener)
        
        // Listen to Dhikrs
        let dhikrsListener = userRef.collection("dhikrs")
            .order(by: "lastUpdated", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "Zikirler yüklenirken hata oluştu: \(error.localizedDescription)"
                        self.showError = true
                    }
                    print("Error getting dhikrs: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                self.dhikrs = documents.compactMap { doc -> DhikrItem? in
                    try? doc.data(as: DhikrItem.self)
                }
            }
        firestoreListenerCancellables.append(dhikrsListener)
        
        // Listen to Daily Logs
        let logsListener = userRef.collection("dailyLogs")
            .order(by: "dateString", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    Task { @MainActor in
                        self.errorMessage = "Günlük istatistikler yüklenirken hata oluştu: \(error.localizedDescription)"
                        self.showError = true
                    }
                    print("Error getting dailyLogs: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else { return }
                
                self.dailyLogs = documents.compactMap { doc -> DailyLog? in
                    try? doc.data(as: DailyLog.self)
                }
                
                // Arkaplandan gelen tıklamaları işle
                self.processWidgetClicks()
            }
        firestoreListenerCancellables.append(logsListener)
            
        // Listen to Categories
        let categoriesListener = userRef.collection("categories")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting categories: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self.categories = documents.compactMap { try? $0.data(as: DhikrCategory.self) }
            }
        firestoreListenerCancellables.append(categoriesListener)
    }
    
    // MARK: - CRUD Operations (Categories)
    func addCategory(name: String, iconName: String, colorHex: String) {
        guard let userRef = userDocRef() else { return }
        let newCategory = DhikrCategory(
            name: name,
            iconName: iconName,
            colorHex: colorHex,
            createdAt: Date()
        )
        _ = try? userRef.collection("categories").addDocument(from: newCategory)
    }
    
    func deleteCategory(_ category: DhikrCategory) {
        guard let userRef = userDocRef(), let id = category.id else { return }
        // Update all dhikrs in this category to nil (Other)
        let dhikrsToUpdate = dhikrs.filter { $0.categoryId == id }
        for var d in dhikrsToUpdate {
            d.categoryId = nil
            updateDhikr(d)
        }
        // Delete category
        userRef.collection("categories").document(id).delete()
    }
    
    // MARK: - CRUD Operations (DhikrItem)
    func addDhikr(name: String, targetCount: Int, categoryId: String? = nil) {
        guard let userRef = userDocRef() else { return }
        let newDhikr = DhikrItem(
            name: name,
            currentCount: 0,
            targetCount: targetCount,
            createdAt: Date(),
            lastUpdated: Date(),
            isArchived: false,
            categoryId: categoryId
        )
        do {
            try userRef.collection("dhikrs").addDocument(from: newDhikr)
        } catch {
            Task { @MainActor in
                self.errorMessage = "Zikir eklenemedi. Lütfen internet bağlantınızı kontrol edin."
                self.showError = true
            }
            print("Error adding dhikr: \(error.localizedDescription)")
        }
    }
    
    func updateDhikr(_ dhikr: DhikrItem) {
        guard let userRef = userDocRef(), let id = dhikr.id else { return }
        var updatedDhikr = dhikr
        updatedDhikr.lastUpdated = Date()
        do {
            try userRef.collection("dhikrs").document(id).setData(from: updatedDhikr)
            
            // Eğer bu öğe aktif zikirse, Widget'a gönder
            if UserDefaults.standard.string(forKey: "active_dhikr_id") == id {
                syncToWidget(item: updatedDhikr)
            }
        } catch {
            Task { @MainActor in
                self.errorMessage = "Zikir güncellenemedi. Değişiklikler kaydedilmemiş olabilir."
                self.showError = true
            }
            print("Error updating dhikr: \(error.localizedDescription)")
        }
    }
    
    func deleteDhikr(_ dhikr: DhikrItem) {
        guard let userRef = userDocRef(), let id = dhikr.id else { return }
        userRef.collection("dhikrs").document(id).delete { error in
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Zikir silinemedi: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    // MARK: - Daily Logging (Zikir Count Activity)
    func logDailyZikir(count: Int) {
        guard let userRef = userDocRef() else { return }
        
        // Bugünün tarihini YYYY-MM-DD olarak al
        let todayString = DateHelper.todayString
        
        let logRef = userRef.collection("dailyLogs").document(todayString)
        
        // FieldValue.increment kullanarak race condition olmadan atomik artırım yapıyoruz
        logRef.setData([
            "dateString": todayString,
            "totalZikirs": FieldValue.increment(Int64(count))
        ], merge: true)
        
        Task { @MainActor in
            self.updateStreak(todayString: todayString)
            
            // Eğer zikir yapıldıysa ve hatırlatıcılar açıksa, bugünün hatırlatıcısını iptal edip yarından başlat
            if count > 0 && UserDefaults.standard.bool(forKey: "daily_reminder_enabled") {
                NotificationManager.shared.rescheduleAllRemindersForTomorrow()
            }
        }
    }
    
    // MARK: - Streak System
    private func updateStreak(todayString: String) {
        guard let userRef = userDocRef(), var profile = userProfile else { return }
        
        // Eğer zaten bugün aktif olmuşsa streak güncellemeye gerek yok
        if profile.lastActiveDate == todayString {
            return
        }
        
        // Dünün tarihini bul
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayString = DateHelper.string(from: yesterday)
        
        if profile.lastActiveDate == yesterdayString {
            // Seri devam ediyor
            profile.currentStreak += 1
        } else {
            // Seri bozulmuş, yeniden başlıyor
            profile.currentStreak = 1
        }
        
        // Max streak kontrolü
        if profile.currentStreak > profile.maxStreak {
            profile.maxStreak = profile.currentStreak
        }
        
        profile.lastActiveDate = todayString
        
        // Firestore'a kaydet
        try? userRef.setData(from: profile, merge: true)
    }
    
    // MARK: - User Metadata (Subscription)
    func updateUserProStatus(isPro: Bool) {
        guard let userRef = userDocRef() else { return }
        
        // Sadece isPro alanını, varsa diğer verileri ezmeden güncelle (merge: true eşdeğeri olarak updateData).
        // Eğer döküman hiç yoksa diye setData ile merge kullanıyoruz.
        userRef.setData(["isPro": isPro], merge: true) { [weak self] error in
            if let error = error {
                Task { @MainActor [weak self] in
                    self?.errorMessage = "Premium statüsü güncellenirken bir hata oluştu: \(error.localizedDescription)"
                    self?.showError = true
                }
                print("Error updating user Pro status in Firestore: \(error.localizedDescription)")
            } else {
                print("Firebase: User Pro status successfully updated to \(isPro)")
            }
        }
    }
    
    // MARK: - Update User Profile
    func updateDisplayName(to newName: String) {
        guard let userRef = userDocRef(), var profile = userProfile else { return }
        
        // Boş bırakılırsa yeni bir random kullanıcı adı ata
        let finalName = newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "user\(Int.random(in: 100000...999999))" : newName
        
        profile.displayName = finalName
        try? userRef.setData(from: profile, merge: true)
    }
    
    // MARK: - Account Deletion
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        Task {
            do {
                // 1. Delete user from Firestore Leaderboard/Profile DB
                try? await db.collection("users").document(uid).delete()
                
                // 2. Delete Auth context
                do {
                    try await user.delete()
                } catch let error as NSError {
                    if error.domain == AuthErrorDomain {
                        // Kullanıcı bulunamadıysa (17011) veya yeniden giriş gerekiyorsa (17014), oturumu kapat
                        try? Auth.auth().signOut()
                    } else {
                        throw error
                    }
                }
                
                await MainActor.run {
                    self.dhikrs.removeAll()
                    self.userProfile = nil
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "\(String(localized: "error_title")): \(error.localizedDescription)"
                    self.showError = true
                }
                print("Failed to delete account: \(error)")
            }
        }
    }
    
    // MARK: - WidgetKit Integration
    func syncToWidget(item: DhikrItem) {
        if let defaults = UserDefaults(suiteName: "group.com.cagriozay.DhikrPulse") {
            defaults.set(item.name, forKey: "widget_dhikr_name")
            defaults.set(item.currentCount, forKey: "widget_dhikr_count")
            defaults.set(item.targetCount, forKey: "widget_dhikr_target")
            
            // Force Widget update
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
    
    func processWidgetClicks() {
        if let defaults = UserDefaults(suiteName: "group.com.cagriozay.DhikrPulse") {
            let pendingClicks = defaults.integer(forKey: "widget_unprocessed_clicks")
            if pendingClicks > 0 {
                let activeId = UserDefaults.standard.string(forKey: "active_dhikr_id") ?? ""
                if var activeItem = dhikrs.first(where: { $0.id == activeId }) {
                    activeItem.currentCount += pendingClicks
                    updateDhikr(activeItem)
                    logDailyZikir(count: pendingClicks)
                }
                defaults.set(0, forKey: "widget_unprocessed_clicks")
            }
        }
    }
}
