import Foundation
import FirebaseFirestore

struct DhikrItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var currentCount: Int
    var targetCount: Int
    var createdAt: Date
    var lastUpdated: Date
    var isArchived: Bool
    
    // Optional category for classification
    var categoryId: String?
    
    // Custom CodingKeys are optional but good practice
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case currentCount
        case targetCount
        case createdAt
        case lastUpdated
        case isArchived
        case categoryId
    }
}

struct DailyLog: Identifiable, Codable {
    @DocumentID var id: String?
    var dateString: String // "YYYY-MM-DD" used as a unique identifier per day for a user
    var totalZikirs: Int
    
    // Hashable konformasyonundan kurtulabiliriz veya manuel yazabiliriz,
    // DailyLog sadece liste/grafik için kullanılacak.
}

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    var isPro: Bool
    var currentStreak: Int
    var maxStreak: Int
    var lastActiveDate: String // YYYY-MM-DD
    var displayName: String? // Opsiyonel, kullanıcı belirlemezse varsayılan üretilecek
    
    init(id: String? = nil, isPro: Bool = false, currentStreak: Int = 0, maxStreak: Int = 0, lastActiveDate: String = "", displayName: String? = nil) {
        self.id = id
        self.isPro = isPro
        self.currentStreak = currentStreak
        self.maxStreak = maxStreak
        self.lastActiveDate = lastActiveDate
        self.displayName = displayName
    }
}

// MARK: - Gamification
struct Achievement: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String // SF Symbol name
    let requiredTotal: Int
    let requiredStreak: Int
    
    // Uygulama geneli statik başarımlar listesi
    static let all: [Achievement] = [
        Achievement(id: "first_step", name: "İlk Adım", description: "100 zikre ulaştın", icon: "star.fill", requiredTotal: 100, requiredStreak: 0),
        Achievement(id: "beginner", name: "Başlangıç", description: "1.000 zikre ulaştın", icon: "medal.fill", requiredTotal: 1000, requiredStreak: 0),
        Achievement(id: "dedicated", name: "Adanmış", description: "10.000 zikre ulaştın", icon: "crown.fill", requiredTotal: 10000, requiredStreak: 0),
        Achievement(id: "master", name: "Usta", description: "100.000 zikre ulaştın", icon: "diamond.fill", requiredTotal: 100000, requiredStreak: 0),
        
        Achievement(id: "streak_3", name: "İstikrar", description: "3 gün üst üste zikir", icon: "flame.fill", requiredTotal: 0, requiredStreak: 3),
        Achievement(id: "streak_7", name: "Haftalık Seri", description: "7 gün üst üste zikir", icon: "bolt.fill", requiredTotal: 0, requiredStreak: 7),
        Achievement(id: "streak_30", name: "Aylık Seri", description: "30 gün üst üste zikir", icon: "calendar.badge.clock", requiredTotal: 0, requiredStreak: 30)
    ]
}

// MARK: - Premium Backgrounds
enum ZikirBackgroundType: String, CaseIterable, Identifiable {
    case classic = "classic"
    case islamic = "islamic"
    case dynamicMesh = "dynamicMesh"
    case darkTexture = "darkTexture"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .classic: return "Klasik (Ücretsiz)"
        case .islamic: return "İslami Desen"
        case .dynamicMesh: return "Dinamik Ağ"
        case .darkTexture: return "Karanlık Doku"
        }
    }
    
    var isPremium: Bool {
        return self != .classic
    }
    
    var iconName: String {
        switch self {
        case .classic: return "square.fill"
        case .islamic: return "moon.stars.fill"
        case .dynamicMesh: return "camera.filters"
        case .darkTexture: return "aqi.medium"
        }
    }
}

// MARK: - Category Model
struct DhikrCategory: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var iconName: String
    var colorHex: String
    var createdAt: Date
    
    // Virtual "default/other" category ID for UI grouping
    static let otherCategoryId = "other_category_id"
}
