import SwiftUI
import StoreKit

struct PremiumStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    
    // Uygulama geneli AppStorage tanımları
    @AppStorage("premium_theme_color") private var selectedTheme: String = "emerald"
    @AppStorage("premium_touchpad_style") private var touchpadStyle: String = "classic"
    
    // Tema verileri
    let themes = [
        ("emerald", "theme_emerald", Color(red: 0.12, green: 0.84, blue: 0.45), true),
        ("sapphire", "theme_sapphire", Color(red: 0.12, green: 0.53, blue: 0.90), false),
        ("ruby", "theme_ruby", Color(red: 0.86, green: 0.15, blue: 0.27), false),
        ("gold", "theme_gold", Color(red: 0.85, green: 0.65, blue: 0.13), false),
        ("amethyst", "theme_amethyst", Color(red: 0.61, green: 0.35, blue: 0.71), false)
    ]
    
    // Dokunma alanı verileri
    let touchpads = [
        ("classic", "pad_classic", "touchid", "pad_classic_desc", true),
        ("wood", "pad_wood", "leaf.fill", "pad_wood_desc", false),
        ("water", "pad_water", "drop.fill", "pad_water_desc", false)
    ]
    
    // Geri almak için orijinal seçimleri tutacak state'ler
    @State private var originalTheme: String = ""
    @State private var originalTouchpad: String = ""
    
    // Seçili temanın rengini dinamik olarak UI'da kullanmak için
    var activeColor: Color {
        themes.first(where: { $0.0 == selectedTheme })?.2 ?? Color(red: 0.12, green: 0.84, blue: 0.45) // Zümrüt
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // MARK: - Hero Banner
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.9), Color.red.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("pro_store")
                                        .font(.system(size: 34, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                                    
                                    Text("pro_store_desc")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.8))
                                    .rotationEffect(.degrees(15))
                                    .offset(x: 10, y: 10)
                            }
                            .padding(24)
                        }
                        .frame(height: 160)
                        .cornerRadius(24)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .shadow(color: Color.orange.opacity(0.25), radius: 20, x: 0, y: 10)
                        
                        // MARK: - Pro Avantajları
                        if !storeManager.isPro {
                            VStack(spacing: 12) {
                                ProFeatureRow(icon: "nosign", title: "no_ads", desc: "no_ads_desc", color: .red)
                                ProFeatureRow(icon: "infinity", title: "unlimited_dhikr", desc: "unlimited_dhikr_desc", color: .blue)
                                ProFeatureRow(icon: "paintpalette.fill", title: "special_themes", desc: "special_themes_desc", color: .purple)
                                ProFeatureRow(icon: "chart.bar.xaxis", title: "advanced_stats", desc: "advanced_stats_desc", color: .green)
                                ProFeatureRow(icon: "rectangle.3.group", title: "widgets", desc: "widgets_desc", color: .orange)
                            }
                            .padding(.horizontal)
                        }
                        
                        // MARK: - Özel Temalar Bölümü
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("premium_themes")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(themes, id: \.0) { theme in
                                        StoreThemeCard(
                                            id: theme.0,
                                            name: theme.1,
                                            color: theme.2,
                                            isFree: theme.3,
                                            isSelected: selectedTheme == theme.0,
                                            isPremium: storeManager.isPro
                                        ) {
                                            // Önizleme (Try Before You Buy)
                                            withAnimation { selectedTheme = theme.0 }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                        
                        // MARK: - Dokunma Alanları Bölümü
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("haptic_pads")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(touchpads, id: \.0) { pad in
                                        StoreTouchpadCard(
                                            id: pad.0,
                                            title: pad.1,
                                            icon: pad.2,
                                            desc: pad.3,
                                            isFree: pad.4,
                                            isSelected: touchpadStyle == pad.0,
                                            isPremium: storeManager.isPro,
                                            activeColor: activeColor
                                        ) {
                                            // Önizleme (Try Before You Buy)
                                            withAnimation { touchpadStyle = pad.0 }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // MARK: - Sticky Purchase Bar
                VStack {
                    Spacer()
                    if !storeManager.isPro {
                        VStack(spacing: 12) {
                            if let product = storeManager.currentSubscription {
                                Button {
                                    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                    impactHeavy.impactOccurred()
                                    
                                    // Gerçek satın alma işlemini başlat
                                    Task {
                                        do {
                                            try await storeManager.purchase(product)
                                        } catch {
                                            print("Purchase failed: \(error)")
                                        }
                                    }
                                } label: {
                                        HStack {
                                            Text(selectedTheme != originalTheme || touchpadStyle != originalTouchpad ? "open_preview" : "unlock_all")
                                                .font(.headline.bold())
                                            Spacer()
                                            Text(product.displayPrice)
                                                .font(.headline.bold())
                                        }
                                        .padding()
                                        .foregroundColor(Color.themeBackground)
                                        .background(activeColor)
                                    .shadow(color: activeColor.opacity(0.5), radius: 10, y: 5)
                                    .cornerRadius(16)
                                }
                                
                                Text(product.description)
                                    .font(.caption2)
                                    .foregroundColor(.themeSecondaryText)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    storeManager.restorePurchases()
                                } label: {
                                    Text("restore_purchases")
                                        .font(.caption2.bold())
                                        .foregroundColor(activeColor)
                                }
                                .padding(.top, 4)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: activeColor))
                                    .padding()
                            }
                        }
                        .padding(20)
                        .background(
                            Color.themeCard
                                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
                        )
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.yellow)
                            Text("pro_active")
                                .font(.headline)
                                .foregroundColor(.themePrimaryText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Color.themeCard
                                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
                        )
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle("store_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    CircleIconButton(icon: "xmark") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                originalTheme = selectedTheme
                originalTouchpad = touchpadStyle
            }
            .onDisappear {
                if !storeManager.isPro {
                    // Ücretsiz olmayan temayı veya touchpad'i seçtiyse ve satın almadan çıktıysa geri al.
                    let isCurrentThemeFree = themes.first(where: { $0.0 == selectedTheme })?.3 ?? true
                    let isCurrentTouchpadFree = touchpads.first(where: { $0.0 == touchpadStyle })?.4 ?? true
                    
                    if !isCurrentThemeFree {
                        selectedTheme = originalTheme
                    }
                    if !isCurrentTouchpadFree {
                        touchpadStyle = originalTouchpad
                    }
                }
            }
        }
    }
}

// MARK: - Store Theme Card Component
struct StoreThemeCard: View {
    let id: String
    let name: String
    let color: Color
    let isFree: Bool
    let isSelected: Bool
    let isPremium: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Color Display Bubble
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 80, height: 80)
                        .shadow(color: color.opacity(0.4), radius: 10, y: 5)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    } else if !isPremium && !isFree {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(8)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                }
                
                Text(name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .semibold)
                    .foregroundColor(isSelected ? .white : .themeSecondaryText)
                
                // Status Pill
                Text(isSelected ? "previewing" : (isFree || isPremium ? "owned" : "pro_badge"))
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isSelected ? color : (isFree || isPremium ? Color.themeBackground : Color.yellow.opacity(0.2)))
                    .foregroundColor(isSelected ? .white : (isFree || isPremium ? .themeSecondaryText : .yellow))
                    .cornerRadius(8)
            }
            .padding()
            .frame(width: 140, height: 200)
            .background(Color.themeCard)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Store Touchpad Card Component
struct StoreTouchpadCard: View {
    let id: String
    let title: String
    let icon: String
    let desc: String
    let isFree: Bool
    let isSelected: Bool
    let isPremium: Bool
    let activeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? activeColor.opacity(0.2) : Color.themeBackground)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: icon)
                            .font(.title)
                            .foregroundColor(isSelected ? activeColor : .themeSecondaryText)
                    }
                    Spacer()
                    
                    if !isPremium && !isFree {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.yellow)
                            .font(.subheadline)
                            .padding(8)
                            .background(Color.yellow.opacity(0.2))
                            .clipShape(Circle())
                    } else if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(activeColor)
                            .font(.title2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.themePrimaryText)
                    
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Status Pill
                HStack {
                    Text(isSelected ? "previewing" : (isFree || isPremium ? "use_badge" : "pro_badge"))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSelected ? activeColor : (isFree || isPremium ? Color.themeBackground : Color.yellow.opacity(0.2)))
                        .foregroundColor(isSelected ? .themeBackground : (isFree || isPremium ? .themeSecondaryText : .yellow))
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
            .padding()
            .frame(width: 180, height: 200)
            .background(Color.themeCard)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? activeColor : Color.clear, lineWidth: 2)
            )
        }
    }
}
// MARK: - Pro Feature Row Component
struct ProFeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
                
                Text(desc)
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.themeCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.themePrimaryText.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    PremiumStoreView()
}
