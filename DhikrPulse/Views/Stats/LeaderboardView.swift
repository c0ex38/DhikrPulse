import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @EnvironmentObject private var dhikrViewModel: DhikrViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading && viewModel.topUsers.isEmpty {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .themeAccent))
                    .scaleEffect(1.5)
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                    .padding(.bottom, 8)
                Text(error)
                    .foregroundColor(.themeSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("try_again") {
                    viewModel.fetchTopUsers()
                }
                .padding()
                .background(Color.themeAccent.opacity(0.2))
                .foregroundColor(.themeAccent)
                .cornerRadius(10)
                Spacer()
            } else if viewModel.topUsers.isEmpty {
                Spacer()
                Text("no_stats_yet")
                    .foregroundColor(.themeSecondaryText)
                Spacer()
            } else {
                List {
                    ForEach(Array(viewModel.topUsers.enumerated()), id: \.element.id) { index, user in
                        let isCurrentUser = (user.id == dhikrViewModel.currentUserId)
                        LeaderboardRowView(index: index, user: user, isCurrentUser: isCurrentUser)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.fetchTopUsers()
                }
            }
        }
        .onAppear {
            if viewModel.topUsers.isEmpty {
                viewModel.fetchTopUsers()
            }
        }
    }
}

struct LeaderboardRowView: View {
    let index: Int
    let user: UserProfile
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Icon
            ZStack {
                if index == 0 {
                    Image(systemName: "medal.fill")
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Altın
                        .font(.title2)
                } else if index == 1 {
                    Image(systemName: "medal.fill")
                        .foregroundColor(Color(red: 0.75, green: 0.75, blue: 0.75)) // Gümüş
                        .font(.title2)
                } else if index == 2 {
                    Image(systemName: "medal.fill")
                        .foregroundColor(Color(red: 0.8, green: 0.5, blue: 0.2)) // Bronz
                        .font(.title2)
                } else {
                    Text("\(index + 1)")
                        .font(.headline)
                        .foregroundColor(.themeSecondaryText)
                }
            }
            .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName ?? "anonymous_user")
                    .font(.headline)
                    .foregroundColor(isCurrentUser ? .themeAccent : .themePrimaryText)
                    .lineLimit(1)
                
                if isCurrentUser {
                    Text("you_badge")
                        .font(.caption.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.themeAccent.opacity(0.2))
                        .foregroundColor(.themeAccent)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
            
            // Stats Segment
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("\(user.currentStreak)")
                        .font(.subheadline.bold())
                        .foregroundColor(.themePrimaryText)
                }
                Text("\("max_streak"): \(user.maxStreak)")
                    .font(.caption2)
                    .foregroundColor(.themeSecondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.themeCard)
            .cornerRadius(10)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .listRowSeparatorTint(Color.white.opacity(0.1))
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(DhikrViewModel())
}
