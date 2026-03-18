import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    
    // Uygulama geneli seçili zikrin ID'sini tutmak için
    @AppStorage("active_dhikr_id") private var activeDhikrIdAsString: String = ""
    @State private var selectedTab = 0
    
    var activeDhikr: DhikrItem? {
        if let found = viewModel.dhikrs.first(where: { $0.id == activeDhikrIdAsString }) {
            return found
        }
        return viewModel.dhikrs.first
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Counter
            Group {
                if let dhikr = activeDhikr {
                    CounterView(dhikrItemId: dhikr.id)
                } else {
                    // Fallback empty view when no items exist
                    VStack {
                        Text("Aktif Zikir Bulunamadı.")
                            .foregroundColor(.white)
                        Button("Hazır Zikirleri Ekle") {
                            createDefaultDhikrs()
                        }
                        .padding()
                        .background(Color.themeAccent)
                        .foregroundColor(Color.themeBackground)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.themeBackground.ignoresSafeArea())
                }
            }
            .tabItem {
                Image(systemName: "timer")
                Text("Sayaç")
            }
            .tag(0)
            
            // Tab 2: Qibla Compass
            QiblaCompassView()
                .tabItem {
                    Image(systemName: "location.north.line.fill")
                    Text("Kıble")
                }
            .tag(1)
            
            // Tab 3: Dhikr List
            DhikrListView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Kütüphane")
                }
            .tag(2)
            
            // Tab 4: Stats
            InsightsStatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("İstatistikler")
                }
            .tag(3)
            
            // Tab 5: Settings
            SettingsGoalsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ayarlar")
                }
            .tag(4)
        }
        .accentColor(.themeAccent) // Use global custom accent color
        .onAppear {
            setupTabBarAppearance()
            if viewModel.dhikrs.isEmpty && viewModel.currentUserId != nil {
                // Sadece kullanıcı girişi tamamlandıysa ve zikir yoksa varsayılanları yarat
                createDefaultDhikrs()
            }
        }
        .alert("Hata", isPresented: $viewModel.showError) {
            Button("Tamam", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Bilinmeyen bir hata oluştu.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.themeBackground)
        
        // Unselected items
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        // Selected items
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.themeAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.themeAccent)]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    private func createDefaultDhikrs() {
        // Prevent duplication if they already clicked
        guard viewModel.dhikrs.isEmpty else { return }
        
        let defaults = [
            ("Sübhanallah", 33),
            ("Elhamdülillah", 33),
            ("Allahu Ekber", 33)
        ]
        
        for item in defaults {
            viewModel.addDhikr(name: item.0, targetCount: item.1)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(DhikrViewModel())
}
