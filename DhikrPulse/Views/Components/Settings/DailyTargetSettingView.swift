import SwiftUI

struct DailyTargetSettingView: View {
    @AppStorage("default_target") private var defaultTarget: Int = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(icon: "target", title: "GÜNLÜK HEDEF")
            
            VStack(spacing: 20) {
                Text("\(defaultTarget)")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(.themeAccent)
                    .contentTransition(.numericText())
                
                Text("Oturum başına tekrar")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)
                
                // Target Selection Pills
                HStack(spacing: 10) {
                    ForEach([33, 99, 100, 500], id: \.self) { target in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) { defaultTarget = target }
                        }) {
                            Text("\(target)")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(defaultTarget == target ? Color.themeAccent : Color.themeBackground)
                                .foregroundColor(defaultTarget == target ? Color.themeBackground : .themePrimaryText)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .padding()
            .background(Color.themeCard)
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}
