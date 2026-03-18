import SwiftUI

enum SettingsTrailingStyle {
    case chevron, externalLink, proBadge
}

struct SettingsRowView: View {
    var icon: String
    var iconColor: Color
    var title: String
    var subtitle: String
    var trailing: SettingsTrailingStyle
    
    var body: some View {
        HStack {
            IconBox(icon: icon, iconColor: iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.themePrimaryText)
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
}
