import SwiftUI

struct EsmaLibraryView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    @EnvironmentObject private var storeManager: StoreManager
    @State private var searchText = ""
    @State private var showingPremiumSheet = false
    
    private var filteredEsmas: [EsmaItem] {
        if searchText.isEmpty {
            return EsmaItem.all
        } else {
            return EsmaItem.all.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.meaning.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEsmas) { esma in
                            EsmaCardView(esma: esma) {
                                // Add to Dhikr Action
                                if viewModel.dhikrs.count >= 3 && !storeManager.isPro {
                                    showingPremiumSheet = true
                                } else {
                                    viewModel.addDhikr(name: esma.name, targetCount: esma.targetCount)
                                    // Feedback
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("esma_library_title")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "search_esma")
            .sheet(isPresented: $showingPremiumSheet) {
                PremiumStoreView()
            }
        }
    }
}

struct EsmaCardView: View {
    let esma: EsmaItem
    let onAddAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Arabic Text
            Text(esma.arabic)
                .font(.system(size: 32, weight: .medium, design: .serif))
                .foregroundColor(.themeAccent)
                .frame(width: 80, alignment: .center)
            
            // Name & Meaning
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(esma.name)
                        .font(.headline)
                        .foregroundColor(.themePrimaryText)
                    Spacer()
                    Text("\("target"): \(esma.targetCount)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.themeAccent.opacity(0.8))
                        .clipShape(Capsule())
                }
                
                Text(esma.meaning)
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Add Button
            Button(action: onAddAction) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.themeAccent)
            }
        }
        .padding(16)
        .background(Color.themeCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    EsmaLibraryView()
        .environmentObject(DhikrViewModel())
        .environmentObject(StoreManager())
}
