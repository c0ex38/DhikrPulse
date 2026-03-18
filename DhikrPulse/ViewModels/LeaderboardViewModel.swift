import Foundation
import FirebaseFirestore
import Combine

class LeaderboardViewModel: ObservableObject {
    @Published var topUsers: [UserProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchTopUsers() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        db.collection("users")
            .order(by: "currentStreak", descending: true)
            .limit(to: 50)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Sıralama yüklenirken bir sorun oluştu: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let docs = snapshot?.documents else { return }
                    self.topUsers = docs.compactMap { try? $0.data(as: UserProfile.self) }
                }
            }
    }
}
