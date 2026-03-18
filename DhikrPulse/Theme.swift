import SwiftUI

// MARK: - Color Theme Definitions
extension Color {
    // Colors extracted from the Stitch design screenshots
    
    /// The deep dark green/black background (e.g. #0B1612)
    static let themeBackground = Color(red: 0.04, green: 0.09, blue: 0.07)
    
    /// The slightly lighter dark green card backgrounds
    static let themeCard = Color(red: 0.08, green: 0.15, blue: 0.11)
    
    /// Secondary accent/text colors
    static let themeSecondaryText = Color(red: 0.5, green: 0.6, blue: 0.55)
    
    /// Dynamic Accent Color based on user's premium selection
    static var themeAccent: Color {
        let isPremium = UserDefaults.standard.bool(forKey: "is_premium")
        let savedTheme = isPremium ? (UserDefaults.standard.string(forKey: "premium_theme_color") ?? "emerald") : "emerald"
        
        switch savedTheme {
        case "sapphire": return Color(red: 0.12, green: 0.53, blue: 0.90) // Mavi
        case "ruby":     return Color(red: 0.86, green: 0.15, blue: 0.27) // Kırmızı
        case "gold":     return Color(red: 0.85, green: 0.65, blue: 0.13) // Altın
        case "amethyst": return Color(red: 0.61, green: 0.35, blue: 0.71) // Mor
        case "custom":
            // Eğer özel renk seçilmişse HEX kodundan oku
            if let hexString = UserDefaults.standard.string(forKey: "premium_custom_color_hex"),
               let customColor = Color(hex: hexString) {
                return customColor
            }
            return Color(red: 0.12, green: 0.84, blue: 0.45) // Zümrüt (VarsayılanFallback)
        case "emerald":  fallthrough
        default:         return Color(red: 0.12, green: 0.84, blue: 0.45) // Zümrüt (Varsayılan)
        }
    }
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
