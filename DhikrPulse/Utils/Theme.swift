import SwiftUI

class ThemeCache {
    static let shared = ThemeCache()
    
    var themeBackground: Color!
    var themeCard: Color!
    var themeSecondaryText: Color!
    var themePrimaryText: Color!
    var themeAccent: Color!
    
    private init() {
        reload()
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: .main) { _ in
            self.reload()
        }
    }
    
    func reload() {
        if let hex = UserDefaults.standard.string(forKey: "custom_background_hex"), let c = Color(hex: hex) {
            themeBackground = c
        } else {
            themeBackground = Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.04, green: 0.09, blue: 0.07, alpha: 1.0)
                    : UIColor(red: 0.96, green: 0.97, blue: 0.96, alpha: 1.0)
            })
        }
        
        if let hex = UserDefaults.standard.string(forKey: "custom_card_hex"), let c = Color(hex: hex) {
            themeCard = c
        } else {
            themeCard = Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.08, green: 0.15, blue: 0.11, alpha: 1.0)
                    : UIColor.white
            })
        }
        
        if let hex = UserDefaults.standard.string(forKey: "custom_text_hex"), let c = Color(hex: hex) {
            themeSecondaryText = c
        } else {
            themeSecondaryText = Color(UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark
                    ? UIColor(red: 0.5, green: 0.6, blue: 0.55, alpha: 1.0)
                    : UIColor(red: 0.4, green: 0.45, blue: 0.42, alpha: 1.0)
            })
        }
        
        themePrimaryText = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0)
        })
        
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        let savedTheme = isPremium ? (UserDefaults.standard.string(forKey: "premium_theme_color") ?? "emerald") : "emerald"
        
        switch savedTheme {
        case "sapphire": themeAccent = Color(red: 0.12, green: 0.53, blue: 0.90)
        case "ruby":     themeAccent = Color(red: 0.86, green: 0.15, blue: 0.27)
        case "gold":     themeAccent = Color(red: 0.85, green: 0.65, blue: 0.13)
        case "amethyst": themeAccent = Color(red: 0.61, green: 0.35, blue: 0.71)
        case "custom":
            if let hexString = UserDefaults.standard.string(forKey: "premium_custom_color_hex"),
               let customColor = Color(hex: hexString) {
                themeAccent = customColor
            } else {
                themeAccent = Color(red: 0.12, green: 0.84, blue: 0.45)
            }
        case "emerald":  fallthrough
        default:         themeAccent = Color(red: 0.12, green: 0.84, blue: 0.45)
        }
    }
}

// MARK: - Color Theme Definitions
extension Color {
    static var themeBackground: Color { ThemeCache.shared.themeBackground }
    static var themeCard: Color { ThemeCache.shared.themeCard }
    static var themeSecondaryText: Color { ThemeCache.shared.themeSecondaryText }
    static var themePrimaryText: Color { ThemeCache.shared.themePrimaryText }
    static var themeAccent: Color { ThemeCache.shared.themeAccent }
}

// MARK: - Color Hex Conversion
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: CGFloat
        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if hexSanitized.count == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

    func toHex() -> String? {
        // Convert SwiftUI Color to UIColor to extract components
        let uic = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard uic.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // CoreImage colors might fail here, fallback
            return nil
        }
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}

enum AppColorScheme: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
