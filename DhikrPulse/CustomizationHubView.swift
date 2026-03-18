import SwiftUI

enum CustomizationTab: String, CaseIterable, Identifiable {
    case background = "Arka Plan"
    case theme = "Renk Teması"
    case touchpad = "Dokunma Yüzeyi"
    
    var id: String { rawValue }
}

struct ThemeItem: Identifiable {
    let id: String
    let name: String
    let color: Color
    let isFree: Bool
}

struct TouchpadItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let isFree: Bool
}

struct CustomizationHubView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeManager: StoreManager
    
    @State private var selectedTab: CustomizationTab = .background
    @State private var showingPremiumStore = false
    
    // MARK: - AppStorage
    @AppStorage("premium_theme_color") private var selectedTheme: String = "emerald"
    @AppStorage("premium_custom_color_hex") private var customColorHex: String = ""
    @AppStorage("premium_touchpad_style") private var touchpadStyle: String = "classic"
    @AppStorage("background_type") private var selectedBackground: String = ZikirBackgroundType.classic.rawValue
    
    @State private var tempCustomColor: Color = .white
    
    // MARK: - Data
    let themes: [ThemeItem] = [
        ThemeItem(id: "emerald", name: "Zümrüt (Klasik)", color: Color(red: 0.12, green: 0.84, blue: 0.45), isFree: true),
        ThemeItem(id: "sapphire", name: "Safir Mavisi", color: Color(red: 0.12, green: 0.53, blue: 0.90), isFree: false),
        ThemeItem(id: "ruby", name: "Yakut Kırmızısı", color: Color(red: 0.86, green: 0.15, blue: 0.27), isFree: false),
        ThemeItem(id: "gold", name: "Çöl Altını", color: Color(red: 0.85, green: 0.65, blue: 0.13), isFree: false),
        ThemeItem(id: "amethyst", name: "Ametist", color: Color(red: 0.61, green: 0.35, blue: 0.71), isFree: false),
        ThemeItem(id: "custom", name: "Kendi Rengim", color: Color.white, isFree: false) // The actual color will be driven by tempCustomColor
    ]
    
    let touchpads: [TouchpadItem] = [
        TouchpadItem(id: "classic", name: "Klasik", icon: "touchid", description: "Standart yeşil yüzey.", isFree: true),
        TouchpadItem(id: "wood", name: "Ahşap Doku", icon: "leaf.fill", description: "Doğal ahşap hissi veren tasarım.", isFree: false),
        TouchpadItem(id: "water", name: "Su Damlası", icon: "drop.fill", description: "Camgöbeği su efekti.", isFree: false)
    ]
    
    var activeColor: Color {
        if selectedTheme == "custom" {
            // Canlı değişiklikleri yansıtmak için
            return tempCustomColor
        }
        return themes.first(where: { $0.id == selectedTheme })?.color ?? Color(red: 0.12, green: 0.84, blue: 0.45)
    }
    
    private let backgroundColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Customization Picker
                    Picker("Kategori", selection: $selectedTab) {
                        ForEach(CustomizationTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case .background:
                                backgroundSection
                            case .theme:
                                themeSection
                            case .touchpad:
                                touchpadSection
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Özelleştirme Merkezi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(activeColor)
                }
            }
            .sheet(isPresented: $showingPremiumStore) {
                PremiumStoreView()
                    .environmentObject(storeManager)
            }
            .onAppear {
                if !customColorHex.isEmpty, let color = Color(hex: customColorHex) {
                    tempCustomColor = color
                } else {
                    tempCustomColor = Color(red: 0.12, green: 0.84, blue: 0.45)
                }
            }
            // Picker rengini aktif temaya göre ayarlayalım
            .tint(activeColor)
        }
    }
    
    // MARK: - Background Section
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Zikir çekerken arkaplanda görmek istediğiniz temayı seçin.")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
                .padding(.horizontal)
            
            LazyVGrid(columns: backgroundColumns, spacing: 20) {
                ForEach(ZikirBackgroundType.allCases) { type in
                    backgroundCard(for: type)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func backgroundCard(for type: ZikirBackgroundType) -> some View {
        let isSelected = selectedBackground == type.rawValue
        let isLocked = type.isPremium && !storeManager.isPro
        
        return Button {
            if isLocked {
                showingPremiumStore = true
            } else {
                withAnimation(.spring()) {
                    selectedBackground = type.rawValue
                }
            }
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.themeCard)
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay {
                            ZStack {
                                DynamicBackgroundView(type: type)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .opacity(0.8)
                                
                                Image(systemName: type.iconName)
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                        }
                    
                    if isLocked {
                        ZStack {
                            Color.black.opacity(0.6)
                                .cornerRadius(16)
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? activeColor : Color.clear, lineWidth: 4)
                )
                
                HStack(spacing: 4) {
                    Text(type.displayName)
                        .font(.caption)
                        .fontWeight(isSelected ? .bold : .regular)
                        .foregroundColor(isSelected ? activeColor : .themeSecondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    if type.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
    
    // MARK: - Theme Section
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Uygulamanın genel aksan rengini değiştirin.")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
                .padding(.horizontal)
            
            LazyVGrid(columns: backgroundColumns, spacing: 20) {
                ForEach(0..<themes.count, id: \.self) { index in
                    let theme = themes[index]
                    let isLocked = !theme.isFree && !storeManager.isPro
                    let isSelected = selectedTheme == theme.id
                    let isCustomItem = theme.id == "custom"
                    
                    VStack(spacing: 12) {
                        ZStack {
                            if isCustomItem {
                                // Custom Color Picker Element
                                ZStack {
                                    AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center)
                                        .clipShape(Circle())
                                        .frame(height: 80)
                                        .shadow(color: tempCustomColor.opacity(0.5), radius: 10, y: 5)
                                    
                                    Circle()
                                        .fill(Color.themeCard)
                                        .frame(width: 60, height: 60)
                                    
                                    // Sadece renk seçici
                                    ColorPicker("", selection: Binding(
                                        get: { tempCustomColor },
                                        set: { newValue in
                                            tempCustomColor = newValue
                                            if storeManager.isPro {
                                                if let hex = newValue.toHex() {
                                                    customColorHex = hex
                                                }
                                                // Eğer bu item seçili değilse hemen seç
                                                if selectedTheme != "custom" {
                                                    withAnimation { selectedTheme = "custom" }
                                                }
                                            } else {
                                                showingPremiumStore = true
                                            }
                                        }
                                    ))
                                    .labelsHidden()
                                    .scaleEffect(1.5) // Hit area'yı büyüt
                                }
                            } else {
                                // Standard Theme Element
                                Button {
                                    if isLocked {
                                        showingPremiumStore = true
                                    } else {
                                        withAnimation { selectedTheme = theme.id }
                                    }
                                } label: {
                                    Circle()
                                        .fill(theme.color)
                                        .frame(height: 80)
                                        .shadow(color: theme.color.opacity(0.5), radius: 10, y: 5)
                                }
                            }
                            
                            if isLocked {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.6))
                                        .frame(height: 80)
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.white)
                                }
                            } else if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    // Custom color'da checkmark gözüksün ama basılmayı engellemesin diye allowsHitTesting(false)
                                    .allowsHitTesting(false)
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(isSelected ? (isCustomItem ? tempCustomColor : theme.color) : Color.clear, lineWidth: 4)
                                .scaleEffect(1.1)
                        )
                        .padding(.bottom, 8)
                        
                        // Text Label Area
                        if isCustomItem {
                            Button {
                                if isLocked {
                                    showingPremiumStore = true
                                } else {
                                    withAnimation { selectedTheme = "custom" }
                                }
                            } label: {
                                textLabel(themeName: theme.name, isSelected: isSelected, isLocked: isLocked)
                            }
                        } else {
                            textLabel(themeName: theme.name, isSelected: isSelected, isLocked: isLocked)
                        }
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    .background(Color.themeCard)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? activeColor.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func textLabel(themeName: String, isSelected: Bool, isLocked: Bool) -> some View {
        HStack(spacing: 4) {
            Text(themeName)
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? activeColor : .themeSecondaryText)
                .multilineTextAlignment(.center)
            
            if isLocked {
                Image(systemName: "crown.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.yellow)
            }
        }
    }
    
    // MARK: - Touchpad Section
    private var touchpadSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ekranda zikir çekerken dokunduğunuz alanı kişiselleştirin.")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(0..<touchpads.count, id: \.self) { index in
                    let pad = touchpads[index]
                    let isLocked = !pad.isFree && !storeManager.isPro
                    let isSelected = touchpadStyle == pad.id
                    
                    Button {
                        if isLocked {
                            showingPremiumStore = true
                        } else {
                            withAnimation { touchpadStyle = pad.id }
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(isSelected ? activeColor.opacity(0.2) : Color.themeBackground)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: pad.icon)
                                    .font(.title2)
                                    .foregroundColor(isSelected ? activeColor : .themeSecondaryText)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pad.name)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? activeColor : .white)
                                
                                Text(pad.description)
                                    .font(.caption)
                                    .foregroundColor(.themeSecondaryText)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            if isLocked {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.yellow)
                            } else if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(activeColor)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Color.themeCard)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? activeColor : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
