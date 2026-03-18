import SwiftUI

struct SettingsGoalsView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    @State private var showingPremiumStore = false
    @State private var showingNameEditAlert = false
    @State private var showingCustomizationHub = false
    @State private var editedName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header Card
                        UserProfileHeaderView(
                            editedName: $editedName,
                            showingNameEditAlert: $showingNameEditAlert
                        )
                        
                        // PRO Section
                        PremiumUpgradeBannerView(showingPremiumStore: $showingPremiumStore)
                        
                        // Akıllı Hatırlatıcılar
                        ReminderSettingsView()
                            .padding(.horizontal)
                        
                        // Daily Goal
                        DailyTargetSettingView()
                        
                        // Preferences
                        AppPreferencesSectionView(showingCustomizationHub: $showingCustomizationHub)
                        
                        // About & Links
                        AboutLinksSectionView()
                        
                        // Footer
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
        }
    }
    
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
}

#Preview {
    SettingsGoalsView()
        .environmentObject(StoreManager())
        .environmentObject(DhikrViewModel())
}
