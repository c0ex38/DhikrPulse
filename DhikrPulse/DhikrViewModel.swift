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
    
    init() {
        signInAnonymously()
    }
    
    // MARK: - Auth
    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Giriş yapılamadı: \(error.localizedDescription)"
                    self.showError = true
                }
                print("Error signing in anonymously: \(error.localizedDescription)")
                return
            }
            if let user = authResult?.user {
                print("Signed in as UID: \(user.uid)")
                self.currentUserId = user.uid
                self.setupListeners() // Dinleyicileri kullanıcı belli olduktan sonra başlat
            }
        }
    }
    
    // MARK: - Helper: User Collection Reference
    private func userDocRef() -> DocumentReference? {
        guard let uid = currentUserId else { return nil }
        return db.collection("users").document(uid)
    }
    
    // MARK: - Firestore Listeners
    private func setupListeners() {
        guard let userRef = userDocRef() else { return }
        
        // Listen to User Profile
        userRef.addSnapshotListener { documentSnapshot, error in
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
        
        // Listen to Dhikrs
        userRef.collection("dhikrs")
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
        
        // Listen to Daily Logs
        userRef.collection("dailyLogs")
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
            
        // Listen to Categories
        userRef.collection("categories")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting categories: \(error.localizedDescription)")
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self.categories = documents.compactMap { try? $0.data(as: DhikrCategory.self) }
            }
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
        try? userRef.collection("categories").addDocument(from: newCategory)
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
        
        logRef.getDocument { document, error in
            Task { @MainActor in
                if let doc = document, doc.exists {
                    // Günlük kayıt varsa güncelle
                    if let existingLog = try? doc.data(as: DailyLog.self) {
                        var updatedLog = existingLog
                        updatedLog.totalZikirs += count
                        // Eğer totalZikirs 0'ın altına düşerse 0'da tut (örn: geri al butonuna basıldıysa)
                        if updatedLog.totalZikirs < 0 {
                            updatedLog.totalZikirs = 0
                        }
                        try? logRef.setData(from: updatedLog)
                    }
                } else {
                    // Bugün için kayıt yoksa yeni yarat
                    let newCount = max(0, count) // Yeni kayıtta eksi değer olma ihtimalini koru
                    let newLog = DailyLog(dateString: todayString, totalZikirs: newCount)
                    try? logRef.setData(from: newLog)
                }
                
                self.updateStreak(todayString: todayString)
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
                Task { @MainActor in
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
