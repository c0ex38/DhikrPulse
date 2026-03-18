import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class StoreManager: ObservableObject {
    var dhikrViewModel: DhikrViewModel?
    
    @Published var isPro: Bool = false {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "is_premium")
            // Sync to Firebase if ViewModel is available
            dhikrViewModel?.updateUserProStatus(isPro: isPro)
        }
    }
    @Published var currentSubscription: Product?
    @Published var availableProducts: [Product] = []
    
    // The Product ID we define in App Store Connect / local .storekit file
    private let productId = "cozay.DhikrPulse.premium.monthly"
    
    // Store our transaction update task
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        // Start listening to transactions when the app launches
        updateListenerTask = listenForTransactions()
        
        Task {
            await fetchProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // 1. Fetch products from App Store (or local .storekit)
    func fetchProducts() async {
        do {
            let products = try await Product.products(for: [productId])
            self.availableProducts = products
            
            if let sub = products.first {
                self.currentSubscription = sub
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    // 2. See if the user already has an active subscription
    func updateCustomerProductStatus() async {
        var isSubscribed = false
        
        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn't, catch `failedVerification` error.
                let transaction = try checkVerified(result)
                
                // If it's our subscription and it hasn't been revoked
                if transaction.productID == productId {
                    isSubscribed = true
                }
            } catch {
                print("Transaction failed verification: \(error)")
            }
        }
        
        self.isPro = isSubscribed
    }
    
    // 3. Purchase a product
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)
            
            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()
            
            // Always finish a transaction.
            await transaction.finish()
            
        case .userCancelled, .pending:
            break
        default:
            break
        }
    }
    
    // 4. Listen to background transactions (e.g., successful renewals outside app)
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()
                    
                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    // 5. Restore Purchases function (user might be on a new device)
    func restorePurchases() {
        Task {
            // This forces StoreKit to sync entitlements with the App Store
            try? await AppStore.sync()
            await updateCustomerProductStatus()
        }
    }
    
    // Helper to verify transactions cryptographically
    nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
