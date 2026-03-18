import SwiftUI

struct AppPreferencesSectionView: View {
    @AppStorage("haptic_enabled") private var hapticEnabled: Bool = true
    @AppStorage("sound_enabled") private var soundEnabled: Bool = false
    @AppStorage("app_color_scheme") private var schemeType: Int = 0
    @AppStorage("app_lang") private var appLang: String = ""
    
    @Binding var showingCustomizationHub: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "slider.horizontal.3", title: "app_preferences")
            
            VStack(spacing: 0) {
                PreferenceRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "haptic_feedback",
                    subtitle: "haptic_desc",
                    isOn: $hapticEnabled
                )
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                PreferenceRow(
                    icon: "speaker.wave.2.fill",
                    title: "sound_effects",
                    subtitle: "sound_desc",
                    isOn: $soundEnabled
                )
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                Button { showingCustomizationHub = true } label: {
                    SettingsRowView(
                        icon: "paintpalette.fill",
                        iconColor: .purple,
                        title: "appearance_themes",
                        subtitle: "appearance_desc",
                        trailing: .chevron
                    )
                }
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                // Language Selection
                HStack {
                    IconBox(icon: "globe")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("language")
                            .foregroundColor(.themePrimaryText)
                            .font(.body)
                        Text("language_desc")
                            .foregroundColor(.themeSecondaryText)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    Picker("Language", selection: $appLang) {
                        Text("system_language").tag("")
                        Text("Türkçe").tag("tr")
                        Text("English").tag("en")
                        Text("العربية").tag("ar")
                    }
                    .tint(.themeSecondaryText)
                }
                .padding(.vertical, 12)
                .padding(.leading, 12)
                
                Divider()
                    .background(Color.themeSecondaryText.opacity(0.2))
                    .padding(.leading, 60)
                
                // Dark/Light Mode Row
                HStack {
                    IconBox(icon: "moon.fill")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("appearance")
                            .foregroundColor(.themePrimaryText)
                            .font(.body)
                        Text("appearance_mode_desc")
                            .foregroundColor(.themeSecondaryText)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Button(action: { schemeType = 0 }) {
                            Text("system_mode")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(schemeType == 0 ? Color.themeAccent : Color.clear)
                                .foregroundColor(schemeType == 0 ? Color.themeBackground : .themeSecondaryText)
                        }
                        Button(action: { schemeType = 1 }) {
                            Text("light_mode")
                                .font(.caption.bold())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(schemeType == 1 ? Color.themeAccent : Color.clear)
                                .foregroundColor(schemeType == 1 ? Color.themeBackground : .themeSecondaryText)
                        }
                        Button(action: { schemeType = 2 }) {
                            Text("dark_mode")
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
