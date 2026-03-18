import SwiftUI

struct AddDhikrView: View {
    @EnvironmentObject private var viewModel: DhikrViewModel
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPremiumStore = false
    
    @State private var title: String = ""
    @State private var subtitle: String = ""
    @State private var target: Int = 33
    @State private var selectedCategoryId: String = DhikrCategory.otherCategoryId
    @State private var showingAddCategory = false
    
    let targetOptions = [33, 99, 100, 500, 1000]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.themeBackground.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Zikir Bilgileri").foregroundColor(.themeAccent)) {
                        TextField("Zikir Adı (Örn: Sübhanallah)", text: $title)
                        TextField("Anlamı / Alt Başlık (İsteğe bağlı)", text: $subtitle)
                    }
                    .listRowBackground(Color.themeCard)
                    .foregroundColor(.themePrimaryText)
                    
                    Section(header: Text("Kategori / Klasör").foregroundColor(.themeAccent)) {
                        Picker("Klasör Seçin", selection: $selectedCategoryId) {
                            Text("📁 Diğer / Klasörsüz")
                                .tag(DhikrCategory.otherCategoryId)
                            
                            ForEach(viewModel.categories) { category in
                                Text("\(Image(systemName: category.iconName)) \(category.name)")
                                    .tag(category.id ?? "")
                            }
                        }
                        .tint(.themeAccent)
                        
                        Button(action: {
                            showingAddCategory = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Yeni Klasör Oluştur")
                            }
                            .foregroundColor(.themeAccent)
                        }
                    }
                    .listRowBackground(Color.themeCard)
                    .foregroundColor(.themePrimaryText)
                    
                    Section(header: Text("Hedef").foregroundColor(.themeAccent)) {
                        Picker("Hedef", selection: $target) {
                            ForEach(targetOptions, id: \.self) { t in
                                Text("\(t)").tag(t)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color.themeCard)
                }
                .scrollContentBackground(.hidden) // Transparan Form arka planı için (iOS 16+)
            }
            .navigationTitle("Yeni Zikir Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.themeBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(.themeSecondaryText)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveDhikr()
                    }
                    .foregroundColor(.themeAccent)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .colorScheme(.dark) // Bütün sayfa inputlarını gece moduna zorla
        .sheet(isPresented: $showingPremiumStore) {
            PremiumStoreView()
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategoryView()
                .environmentObject(viewModel)
        }
    }
    
    private func saveDhikr() {
        if !storeManager.isPro && viewModel.dhikrs.count >= 3 {
            showingPremiumStore = true
            return
        }
        
        let finalCategoryId = (selectedCategoryId == DhikrCategory.otherCategoryId) ? nil : selectedCategoryId
        viewModel.addDhikr(name: title, targetCount: target, categoryId: finalCategoryId)
        dismiss()
    }
}

#Preview {
    AddDhikrView()
        .environmentObject(DhikrViewModel())
        .environmentObject(StoreManager())
}
