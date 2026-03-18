import SwiftUI

struct AppPreferencesSectionView: View {
    @AppStorage("haptic_enabled") private var hapticEnabled: Bool = true
    @AppStorage("sound_enabled") private var soundEnabled: Bool = false
    @AppStorage("app_color_scheme") private var schemeType: Int = 0
    
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
                            .foregroundColor(.themePrimaryText)
                            .font(.body)
                        Text("Açık & Koyu mod arası geçiş")
                            .foregroundColor(.themeSecondaryText)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button(action: { schemeType = 0 }) {
                            Text("Sistem")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(schemeType == 0 ? Color.themeAccent : Color.clear)
                                .foregroundColor(schemeType == 0 ? Color.themeBackground : .themeSecondaryText)
                        }
                        Button(action: { schemeType = 1 }) {
                            Text("Açık")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(schemeType == 1 ? Color.themeAccent : Color.clear)
                                .foregroundColor(schemeType == 1 ? Color.themeBackground : .themeSecondaryText)
                        }
                        Button(action: { schemeType = 2 }) {
                            Text("Koyu")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(schemeType == 2 ? Color.themeAccent : Color.clear)
                                .foregroundColor(schemeType == 2 ? Color.themeBackground : .themeSecondaryText)
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
