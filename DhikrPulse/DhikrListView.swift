import SwiftUI

struct DhikrListView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    @EnvironmentObject private var storeManager: StoreManager
    
    @Binding var selectedTab: Int
    @AppStorage("active_dhikr_id") private var activeDhikrIdAsString: String = ""
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingPremiumSheet = false
    
    // Derived values for the "Daily Completion" widget based on the Stitch specs
    private var totalTarget: Int {
        viewModel.dhikrs.reduce(0) { $0 + $1.targetCount }
    }
    
    private var totalCount: Int {
        viewModel.dhikrs.reduce(0) { $0 + $1.currentCount }
    }
    
    private var completionPercentage: Double {
        guard totalTarget > 0 else { return 0 }
        let rawPercent = Double(totalCount) / Double(totalTarget)
        return min(rawPercent, 1.0)
    }
    
    private var filteredDhikrs: [DhikrItem] {
        if searchText.isEmpty {
            return viewModel.dhikrs
        } else {
            return viewModel.dhikrs.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Daily Completion Summary Card
                        dailyCompletionCard
                        
                        // Premium Limit Banner for Free Users
                        if !storeManager.isPro {
                            premiumLimitBanner
                        }
                        
                        // Active Dhikrs Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(
                                icon: "list.bullet",
                                title: "AKTİF ZİKİRLER",
                                trailing: "Tümünü Gör"
                            ) {
                                // Action to see more or filter
                            }
                            
                            // The List of Dhikrs
                            ForEach(filteredDhikrs) { dhikr in
                                Button(action: {
                                    if let id = dhikr.id {
                                        activeDhikrIdAsString = id
                                    }
                                    selectedTab = 0 // Switch to Counter tab
                                }) {
                                    DhikrProgressCard(dhikr: dhikr, isActive: activeDhikrIdAsString == dhikr.id)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteDhikr(dhikr)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("DhikrPulse")
            .navigationBarTitleDisplayMode(.inline)
            .darkNavStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            // Add custom search bar matching the deep dark theme
            .searchable(text: $searchText, prompt: "Kütüphanede ara...")
            
            // Add a floating action button for adding new Dhikr
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Enforce 3 Dhikr limit for Free users
                            if viewModel.dhikrs.count >= 3 && !storeManager.isPro {
                                showingPremiumSheet = true
                            } else {
                                showingAddSheet = true
                            }
                        }) {
                            Circle()
                                .fill(Color.themeAccent)
                                .frame(width: 60, height: 60)
                                .shadow(color: .themeAccent.opacity(0.4), radius: 10, x: 0, y: 5)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.title2.bold())
                                        .foregroundColor(Color.themeBackground)
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            )
            .sheet(isPresented: $showingAddSheet) {
                AddDhikrView()
            }
            .sheet(isPresented: $showingPremiumSheet) {
                PremiumStoreView()
            }
        }
    }
    
    // MARK: - Subviews
    private var dailyCompletionCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Günlük İlerleme")
                        .font(.subheadline)
                        .foregroundColor(.themeSecondaryText)
                    
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\(totalCount)")
                            .font(.headline)
                            .foregroundColor(.themeAccent)
                        Text("Toplam")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    Text("BUGÜNKÜ ZİKİR")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                        .tracking(1)
                }
            }
            
            // Custom Thick Progress Bar
            ProgressBarView(progress: completionPercentage, height: 8, trackColor: .themeBackground)
                .padding(.top, 4)
        }
        .padding(20)
        .background(Color.themeCard)
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    // Free User Limit Banner
    private var premiumLimitBanner: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.themeAccent)
            
            let count = viewModel.dhikrs.count
            if count >= 3 {
                Text("Ücretsiz zikir limitine ulaştınız. Sınırsız zikir için Premium'a geçin.")
                    .font(.footnote)
                    .foregroundColor(.white)
            } else {
                Text("Ücretsiz limit: \(count)/3 zikir. Sınırsız için Premium'a geçin.")
                    .font(.footnote)
                    .foregroundColor(.themeSecondaryText)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.themeAccent.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.themeAccent.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .onTapGesture {
            showingPremiumSheet = true
        }
    }
}


// MARK: - Preview setup (Must mock Env Object)
#Preview {
    DhikrListView(selectedTab: .constant(1))
        .environmentObject(DhikrViewModel())
}
