import SwiftUI

struct SettingsGoalsView: View {
    @AppStorage("default_target") private var defaultTarget: Int = 100
    @AppStorage("haptic_enabled") private var hapticEnabled: Bool = true
    @AppStorage("sound_enabled") private var soundEnabled: Bool = false
    @AppStorage("is_dark_mode") private var isDarkMode: Bool = true
    
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var viewModel: DhikrViewModel
    @State private var showingPremiumStore = false
    @State private var showingNameEditAlert = false
    @State private var showingCustomizationHub = false
    @State private var editedName = ""
    
    private var totalLifetimeZikirs: Int {
        viewModel.dailyLogs.reduce(0) { $0 + $1.totalZikirs }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Profile Header Card
                        profileHeaderCard
                        
                        // MARK: - PRO Section
                        proSection
                        
                        // MARK: - Akıllı Hatırlatıcılar
                        ReminderSettingsView()
                            .padding(.horizontal)
                        
                        // MARK: - Customization Button
                        appearanceThemesButton
                        
                        // MARK: - Daily Goal
                        dailyGoalSection
                        
                        // MARK: - Preferences
                        preferencesSection
                        
                        // MARK: - About & Links
                        aboutSection
                        
                        // MARK: - Footer
                        footerSection
                    }
                    .padding(.vertical, 20)
                }
            }
            .sheet(isPresented: $showingPremiumStore) {
                PremiumStoreView()
                    .environmentObject(storeManager)
            }
            .sheet(isPresented: $showingCustomizationHub) {
                CustomizationHubView()
                    .environmentObject(storeManager)
            }
            .alert("Kullanıcı Adı", isPresented: $showingNameEditAlert) {
                TextField("Yeni Adınız", text: $editedName)
                Button("İptal", role: .cancel) { }
                Button("Kaydet") {
                    viewModel.updateDisplayName(to: editedName)
                }
            } message: {
                Text("Profilinizde görünecek yeni bir ad belirleyin.")
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .darkNavStyle()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeaderCard: some View {
        VStack(spacing: 16) {
            // Avatar & Name
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.themeAccent, Color.themeAccent.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(Color.themeBackground)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(viewModel.userProfile?.displayName ?? "Anonim Hesap")
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Edit Icon Button
                        Button {
                            editedName = viewModel.userProfile?.displayName ?? ""
                            showingNameEditAlert = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.themeSecondaryText)
                                .padding(4)
                                .background(Color.themeBackground)
                                .clipShape(Circle())
                        }
                        
                        if storeManager.isPro {
                            Text("PRO")
                                .font(.caption2.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(storeManager.isPro ? "Premium Üye" : "Ücretsiz Hesap")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                }
                
                Spacer()
            }
            
            // Mini Stats Row
            HStack(spacing: 0) {
                // Streak
                miniStatItem(
                    icon: "flame.fill",
                    value: "\(viewModel.userProfile?.currentStreak ?? 0)",
                    label: "Günlük Seri",
                    iconColor: .orange
                )
                
                miniDivider
                
                // Total Zikirs
                miniStatItem(
                    icon: "heart.fill",
                    value: totalLifetimeZikirs > 999 ? "\(totalLifetimeZikirs / 1000)K" : "\(totalLifetimeZikirs)",
                    label: "Toplam Zikir",
                    iconColor: .red
                )
                
                miniDivider
                
                // Max Streak
                miniStatItem(
                    icon: "trophy.fill",
                    value: "\(viewModel.userProfile?.maxStreak ?? 0)",
                    label: "En İyi Seri",
                    iconColor: .yellow
                )
            }
            .padding(.vertical, 12)
            .background(Color.themeBackground)
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private func miniStatItem(icon: String, value: String, label: String, iconColor: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption2)
                .foregroundColor(.themeSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var miniDivider: some View {
        Rectangle()
            .fill(Color.themeSecondaryText.opacity(0.2))
            .frame(width: 1, height: 40)
    }
    
    // MARK: - PRO Section
    private var proSection: some View {
        VStack(spacing: 12) {
            if !storeManager.isPro {
                // Upgrade Banner
                Button {
                    showingPremiumStore = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: "crown.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DhikrPulse PRO'ya Geçin")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Sınırsız zikir, temalar, ısı haritası ve daha fazlası")
                                .font(.caption)
                                .foregroundColor(.themeSecondaryText)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.themeSecondaryText)
                            .font(.caption.bold())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.themeCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.yellow.opacity(0.6), .orange.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .padding(.horizontal)
            } else {
                // Manage Subscription
                Button {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(
                        icon: "creditcard.fill",
                        iconColor: .themeAccent,
                        title: "Aboneliği Yönet",
                        subtitle: "İptal, değiştirme veya yenileme",
                        trailing: .externalLink
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Customization
    private var appearanceThemesButton: some View {
        Button {
            showingCustomizationHub = true
        } label: {
            settingsRow(
                icon: "paintpalette.fill",
                iconColor: .purple,
                title: "Görünüm & Temalar",
                subtitle: "Arka plan, renk ve dokunma yüzeyi",
                trailing: .chevron
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Daily Goal Section
    private var dailyGoalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "target", title: "GÜNLÜK HEDEF")
            
            VStack(spacing: 20) {
                Text("\(defaultTarget)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.themeAccent)
                    .contentTransition(.numericText())
                
                Text("Oturum başına tekrar")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
                
                // Target Selection Pills
                HStack(spacing: 10) {
                    ForEach([33, 99, 100, 500], id: \.self) { target in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) { defaultTarget = target }
                        }) {
                            Text("\(target)")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(defaultTarget == target ? Color.themeAccent : Color.themeBackground)
                                .foregroundColor(defaultTarget == target ? Color.themeBackground : .white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            .background(Color.themeCard)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "slider.horizontal.3", title: "UYGULAMA TERCİHLERİ")
            
            VStack(spacing: 0) {
                PreferenceRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "Titreşim (Haptic)",
                    subtitle: "Her sayımda hafif titreşim",
                    isOn: $hapticEnabled
                )
                
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 60)
                
                PreferenceRow(
                    icon: "speaker.wave.2.fill",
                    title: "Ses Efektleri",
                    subtitle: "Hafif bir tıklama sesi oynat",
                    isOn: $soundEnabled
                )
                
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 60)
                
                Button { showingCustomizationHub = true } label: {
                    settingsRow(
                        icon: "paintpalette.fill",
                        iconColor: .purple,
                        title: "Görünüm & Temalar",
                        subtitle: "Arka plan, renkler ve dokunma alanı",
                        trailing: .chevron
                    )
                }
                
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 60)
                
                // Dark/Light Mode Row
                HStack {
                    IconBox(icon: "moon.fill")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Görünüm")
                            .foregroundColor(.white)
                            .font(.body)
                        Text("Açık & Koyu mod arası geçiş")
                            .foregroundColor(.themeSecondaryText)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button(action: { isDarkMode = false }) {
                            Text("Açık")
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isDarkMode ? Color.clear : Color.themeCard)
                                .foregroundColor(isDarkMode ? .themeSecondaryText : .white)
                        }
                        Button(action: { isDarkMode = true }) {
                            Text("Koyu")
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isDarkMode ? Color.themeAccent : Color.clear)
                                .foregroundColor(isDarkMode ? Color.themeBackground : .themeSecondaryText)
                        }
                    }
                    .background(Color.themeBackground)
                    .cornerRadius(8)
                    .padding(.trailing, 8)
                }
                .padding(.vertical, 12)
                .padding(.leading, 12)
            }
            .background(Color.themeCard)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "info.circle", title: "HAKKINDA")
            
            VStack(spacing: 0) {
                Button {
                    storeManager.restorePurchases()
                } label: {
                    settingsRow(
                        icon: "arrow.clockwise",
                        iconColor: .blue,
                        title: "Satın Almaları Geri Yükle",
                        subtitle: "Önceki aboneliğinizi kurtarın",
                        trailing: .chevron
                    )
                }
                
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 60)
                
                Button {
                    if let url = URL(string: "https://apps.apple.com/app/id123456789") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(
                        icon: "star.fill",
                        iconColor: .yellow,
                        title: "Uygulamayı Değerlendirin",
                        subtitle: "App Store'da puanlayın",
                        trailing: .externalLink
                    )
                }
                
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 60)
                
                Button {
                    shareApp()
                } label: {
                    settingsRow(
                        icon: "square.and.arrow.up",
                        iconColor: .green,
                        title: "Arkadaşlarına Öner",
                        subtitle: "DhikrPulse'ı paylaşın",
                        trailing: .chevron
                    )
                }
                
                Divider().background(Color.themeSecondaryText.opacity(0.2)).padding(.leading, 60)
                
                Button {
                    if let url = URL(string: "https://dhikrpulse.app/privacy") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    settingsRow(
                        icon: "hand.raised.fill",
                        iconColor: .purple,
                        title: "Gizlilik Politikası",
                        subtitle: "Verilerinizi nasıl kullandığımız",
                        trailing: .externalLink
                    )
                }
            }
            .background(Color.themeCard)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.fill")
                .foregroundColor(.themeAccent)
                .font(.caption)
            Text("DhikrPulse v1.0.0")
                .font(.caption)
                .foregroundColor(.themeSecondaryText)
            Text("\"Kalbinizi ritimde tutun\"")
                .font(.caption.italic())
                .foregroundColor(.themeAccent.opacity(0.7))
        }
        .padding(.top, 10)
        .padding(.bottom, 30)
    }
    
    // MARK: - Helpers
    private enum TrailingStyle {
        case chevron, externalLink, proBadge
    }
    
    private func settingsRow(icon: String, iconColor: Color, title: String, subtitle: String, trailing: TrailingStyle) -> some View {
        HStack {
            IconBox(icon: icon, iconColor: iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
            }
            
            Spacer()
            
            Group {
                switch trailing {
                case .chevron:
                    Image(systemName: "chevron.right")
                        .foregroundColor(.themeSecondaryText)
                case .externalLink:
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.themeSecondaryText)
                case .proBadge:
                    Text("PRO")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.themeAccent.opacity(0.2))
                        .foregroundColor(.themeAccent)
                        .cornerRadius(6)
                }
            }
            .font(.caption.bold())
            .padding(.trailing, 16)
        }
        .padding(.vertical, 12)
        .padding(.leading, 12)
    }
    
    private func shareApp() {
        let text = "DhikrPulse - Dijital zikir ve dua uygulaması! Hemen indir: https://apps.apple.com/app/id123456789"
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityController, animated: true)
        }
    }
}


#Preview {
    SettingsGoalsView()
        .environmentObject(StoreManager())
        .environmentObject(DhikrViewModel())
}
