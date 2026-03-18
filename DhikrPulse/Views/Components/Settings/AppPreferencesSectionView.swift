import SwiftUI

struct AppPreferencesSectionView: View {
    @AppStorage("haptic_enabled") private var hapticEnabled: Bool = true
    @AppStorage("sound_enabled") private var soundEnabled: Bool = false
    @AppStorage("is_dark_mode") private var isDarkMode: Bool = true
    
    @Binding var showingCustomizationHub: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "slider.horizontal.3", title: "UYGULAMA TERCİHLERİ")
            
            VStack(spacing: 0) {
                PreferenceRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "Titreşim (Haptic)",
                    subtitle: "Her sayımda hafif titreşim",
                    isOn: $hapticEnabled
                )
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                PreferenceRow(
                    icon: "speaker.wave.2.fill",
                    title: "Ses Efektleri",
                    subtitle: "Hafif bir tıklama sesi oynat",
                    isOn: $soundEnabled
                )
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                Button { showingCustomizationHub = true } label: {
                    SettingsRowView(
                        icon: "paintpalette.fill",
                        iconColor: .purple,
                        title: "Görünüm & Temalar",
                        subtitle: "Arka plan, renkler ve dokunma alanı",
                        trailing: .chevron
                    )
                }
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
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
}
