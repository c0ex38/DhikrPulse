import SwiftUI

enum CustomizationTab: String, CaseIterable, Identifiable {
    case background = "tab_background"
    case theme = "tab_theme"
    case touchpad = "tab_touchpad"
    
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
    @Namespace private var animation
    
    // MARK: - AppStorage
    @AppStorage("premium_theme_color") private var selectedTheme: String = "emerald"
    @AppStorage("app_color_scheme") private var schemeType: Int = 0
    @AppStorage("premium_custom_color_hex") private var customColorHex: String = ""
    @AppStorage("custom_background_hex") private var customBackgroundHex: String = ""
    @AppStorage("custom_card_hex") private var customCardHex: String = ""
    @AppStorage("custom_text_hex") private var customTextHex: String = ""
    
    @AppStorage("premium_touchpad_style") private var touchpadStyle: String = "classic"
    @AppStorage("background_type") private var selectedBackground: String = ZikirBackgroundType.classic.rawValue
    
    @State private var tempCustomColor: Color = .white
    @State private var tempCustomBackground: Color = Color(red: 0.04, green: 0.09, blue: 0.07)
    @State private var tempCustomCard: Color = Color(red: 0.08, green: 0.15, blue: 0.11)
    @State private var tempCustomText: Color = Color(red: 0.5, green: 0.6, blue: 0.55)
    
    // MARK: - Data
    let themes: [ThemeItem] = [
        ThemeItem(id: "emerald", name: "theme_emerald", color: Color(red: 0.12, green: 0.84, blue: 0.45), isFree: true),
        ThemeItem(id: "sapphire", name: "theme_sapphire", color: Color(red: 0.12, green: 0.53, blue: 0.90), isFree: false),
        ThemeItem(id: "ruby", name: "theme_ruby", color: Color(red: 0.86, green: 0.15, blue: 0.27), isFree: false),
        ThemeItem(id: "gold", name: "theme_gold", color: Color(red: 0.85, green: 0.65, blue: 0.13), isFree: false),
        ThemeItem(id: "amethyst", name: "theme_amethyst", color: Color(red: 0.61, green: 0.35, blue: 0.71), isFree: false),
        ThemeItem(id: "custom", name: "theme_custom", color: Color.white, isFree: false)
    ]
    
    let touchpads: [TouchpadItem] = [
        TouchpadItem(id: "classic", name: "pad_classic", icon: "touchid", description: "pad_classic_desc", isFree: true),
        TouchpadItem(id: "wood", name: "pad_wood", icon: "leaf.fill", description: "pad_wood_desc", isFree: false),
        TouchpadItem(id: "water", name: "pad_water", icon: "drop.fill", description: "pad_water_desc", isFree: false)
    ]
    
    var activeColor: Color {
        if selectedTheme == "custom" { return tempCustomColor }
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
                    livePreviewHeader
                        .padding(.top, 10)
                        
                    customTabSelector
                        .padding(.vertical, 16)
                    
                    ScrollView(showsIndicators: false) {
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
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("customization_hub")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.themeSecondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingPremiumStore) {
                PremiumStoreView()
                    .environmentObject(storeManager)
            }
            .onAppear(perform: loadCustomColors)
            .tint(activeColor)
        }
    }
    
    // MARK: - Live Preview Header
    private var livePreviewHeader: some View {
        VStack {
            Spacer()
            
            // Fake Counter Mockup
            VStack(spacing: 4) {
                Text("100")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(activeColor)
                    .shadow(color: activeColor.opacity(0.3), radius: 5, y: 3)
                
                Text("select_dhikr")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 16)
            
            // Touchpad Mockup
            ZStack {
                if storeManager.isPro && touchpadStyle == "wood" {
                    Circle()
                        .fill(RadialGradient(gradient: Gradient(colors: [Color(red: 0.5, green: 0.3, blue: 0.1), Color(red: 0.3, green: 0.15, blue: 0.05)]), center: .center, startRadius: 10, endRadius: 60))
                        .overlay(Circle().stroke(activeColor.opacity(0.3), lineWidth: 2))
                } else if storeManager.isPro && touchpadStyle == "water" {
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.6), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
                } else {
                    Circle()
                        .fill(activeColor.opacity(0.15))
                        .overlay(Circle().stroke(activeColor.opacity(0.6), lineWidth: 2))
                }
                
                Image(systemName: "hand.tap.fill")
                    .font(.title)
                    .foregroundColor(touchpadStyle == "water" ? .white : activeColor.opacity(0.8))
            }
            .frame(width: 80, height: 80)
            .shadow(color: activeColor.opacity(0.2), radius: 10, y: 5)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background(
            ZStack {
                if let bgType = ZikirBackgroundType(rawValue: selectedBackground) {
                    DynamicBackgroundView(type: bgType)
                } else {
                    Color.themeCard
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient(colors: [activeColor.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 15, y: 10)
        .padding(.horizontal)
    }
    
    // MARK: - Custom Tab Selector
    private var customTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(CustomizationTab.allCases) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    Text(LocalizedStringKey(tab.rawValue))
                        .font(.footnote.bold())
                        .foregroundColor(selectedTab == tab ? .white : .themeSecondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(activeColor)
                                        .matchedGeometryEffect(id: "TAB_INDICATOR", in: animation)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // MARK: - Background Section
    private var backgroundSection: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: backgroundColumns, spacing: 16) {
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
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeCard)
                        .aspectRatio(0.8, contentMode: .fit)
                        .overlay {
                            DynamicBackgroundView(type: type)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .opacity(isSelected ? 1.0 : 0.7)
                        }
                    
                    if isLocked {
                        ZStack {
                            Color.black.opacity(0.5).cornerRadius(20)
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    } else if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(activeColor).shadow(radius: 4))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? activeColor : Color.clear, lineWidth: 3)
                )
                .shadow(color: isSelected ? activeColor.opacity(0.3) : .clear, radius: 8, y: 4)
                
                HStack(spacing: 4) {
                    Text(type.displayName)
                        .font(.caption.bold())
                        .foregroundColor(isSelected ? activeColor : .themePrimaryText)
                    if type.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
    }
    
    // MARK: - Theme Section
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            // Scheme Selection
            VStack(alignment: .leading, spacing: 12) {
                Text("appearance_mode")
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
                
                HStack(spacing: 12) {
                    schemeButton(title: "system_theme", icon: "iphone", value: 0)
                    schemeButton(title: "light_theme", icon: "sun.max.fill", value: 1)
                    schemeButton(title: "dark_theme", icon: "moon.fill", value: 2)
                }
            }
            .padding(.horizontal)
            
            Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.horizontal)
            
            // Color Themes
            VStack(alignment: .leading, spacing: 16) {
                Text("theme_color")
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
                
                LazyVGrid(columns: backgroundColumns, spacing: 16) {
                    ForEach(themes) { theme in
                        themeCard(for: theme)
                    }
                }
            }
            .padding(.horizontal)
            
            if selectedTheme == "custom" {
                advancedColorPanel
            }
        }
    }
    
    private func schemeButton(title: String, icon: String, value: Int) -> some View {
        Button(action: { withAnimation { schemeType = value } }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(schemeType == value ? activeColor : Color.themeCard)
            .foregroundColor(schemeType == value ? .white : .themeSecondaryText)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(schemeType == value ? activeColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: schemeType == value ? activeColor.opacity(0.3) : .clear, radius: 5, y: 3)
        }
    }
    
    private func themeCard(for theme: ThemeItem) -> some View {
        let isLocked = !theme.isFree && !storeManager.isPro
        let isSelected = selectedTheme == theme.id
        let isCustom = theme.id == "custom"
        let displayColor = isCustom ? tempCustomColor : theme.color
        
        return Button {
            if isLocked {
                showingPremiumStore = true
            } else {
                withAnimation { selectedTheme = theme.id }
                if !isCustom {
                    customBackgroundHex = ""
                    customCardHex = ""
                    customTextHex = ""
                }
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(displayColor)
                        .frame(width: 40, height: 40)
                        .shadow(color: displayColor.opacity(0.4), radius: 5, y: 2)
                    
                    if isCustom {
                        Image(systemName: "paintpalette.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    } else if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                        .font(.subheadline.bold())
                        .foregroundColor(isSelected ? activeColor : .themePrimaryText)
                    if isLocked {
                        Text("PRO")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                Spacer()
            }
            .padding(12)
            .background(Color.themeCard)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? activeColor : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Advanced Color Panel
    private var advancedColorPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(activeColor)
                Text("advanced_color_editor")
                    .font(.headline)
                    .foregroundColor(.themePrimaryText)
            }
            
            VStack(spacing: 0) {
                colorRow(title: "accent_color", selection: $tempCustomColor) { hex in customColorHex = hex }
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 16)
                colorRow(title: "background_color", selection: $tempCustomBackground) { hex in customBackgroundHex = hex }
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 16)
                colorRow(title: "cards_menus", selection: $tempCustomCard) { hex in customCardHex = hex }
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 16)
                colorRow(title: "text_color", selection: $tempCustomText) { hex in customTextHex = hex }
            }
            .background(Color.themeCard)
            .cornerRadius(16)
        }
        .padding()
        .background(Color.themeCard.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private func colorRow(title: String, selection: Binding<Color>, onUpdate: @escaping (String) -> Void) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.themePrimaryText)
            Spacer()
            ColorPicker("", selection: Binding(
                get: { selection.wrappedValue },
                set: { newValue in
                    selection.wrappedValue = newValue
                    if let hex = newValue.toHex() { onUpdate(hex) }
                }
            ))
            .labelsHidden()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Touchpad Section
    private var touchpadSection: some View {
        VStack(spacing: 16) {
            ForEach(touchpads) { pad in
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
                                .fill(isSelected ? activeColor.opacity(0.15) : Color.themeCard)
                                .frame(width: 64, height: 64)
                                .shadow(color: isSelected ? activeColor.opacity(0.2) : .clear, radius: 5, y: 3)
                            
                            Image(systemName: pad.icon)
                                .font(.title)
                                .foregroundColor(isSelected ? activeColor : .themeSecondaryText)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(pad.name)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? activeColor : .themePrimaryText)
                                if isLocked {
                                    Image(systemName: "crown.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                }
                            }
                            Text(pad.description)
                                .font(.caption)
                                .foregroundColor(.themeSecondaryText)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(activeColor)
                        } else if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.themeSecondaryText.opacity(0.5))
                        }
                    }
                    .padding(12)
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
    
    // MARK: - Helper
    private func loadCustomColors() {
        if !customColorHex.isEmpty, let color = Color(hex: customColorHex) { tempCustomColor = color }
        if !customBackgroundHex.isEmpty, let color = Color(hex: customBackgroundHex) { tempCustomBackground = color }
        if !customCardHex.isEmpty, let color = Color(hex: customCardHex) { tempCustomCard = color }
        if !customTextHex.isEmpty, let color = Color(hex: customTextHex) { tempCustomText = color }
    }
}
