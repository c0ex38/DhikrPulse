import SwiftUI

struct AddCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: DhikrViewModel
    
    @State private var categoryName: String = ""
    @State private var selectedIcon: String = "folder.fill"
    @State private var selectedColor: String = "#3B82F6" // Default blue
    
    // Predetermined icons
    let icons = [
        "folder.fill", "moon.stars.fill", "star.fill", "heart.fill",
        "book.fill", "sparkles", "infinity", "sun.max.fill",
        "leaf.fill", "bookmark.fill", "hands.sparkles.fill", "flame.fill"
    ]
    
    // Predetermined Colors (Hex)
    let colors = [
        "#3B82F6", // Blue
        "#EF4444", // Red
        "#10B981", // Emerald
        "#F59E0B", // Amber
        "#8B5CF6", // Violet
        "#EC4899", // Pink
        "#14B8A6", // Teal
        "#6B7280"  // Gray
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kategori Bilgileri")) {
                    TextField("Kategori Adı", text: $categoryName)
                        .autocapitalization(.words)
                }
                
                Section(header: Text("İkon Seçici")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 15) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 24))
                                .foregroundColor(selectedIcon == icon ? (Color(hex: selectedColor) ?? .gray) : .gray)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(selectedIcon == icon ? (Color(hex: selectedColor) ?? .gray).opacity(0.2) : Color.clear)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedIcon = icon
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Renk Seçici")) {
                    HStack(spacing: 15) {
                        ForEach(colors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex) ?? .gray)
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == colorHex ? 2 : 0)
                                        .padding(-4)
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedColor = colorHex
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Yeni Kategori")
            .navigationBarItems(
                leading: Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Kaydet") {
                    saveCategory()
                }
                .disabled(categoryName.trimmingCharacters(in: .whitespaces).isEmpty)
            )
        }
    }
    
    private func saveCategory() {
        viewModel.addCategory(
            name: categoryName.trimmingCharacters(in: .whitespaces),
            iconName: selectedIcon,
            colorHex: selectedColor
        )
        presentationMode.wrappedValue.dismiss()
    }
}
