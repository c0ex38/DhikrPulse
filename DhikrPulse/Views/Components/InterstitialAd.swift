import Foundation
import GoogleMobileAds
import SwiftUI
import Combine

class InterstitialAd: NSObject, GADFullScreenContentDelegate, ObservableObject {
    @Published private var interstitial: GADInterstitialAd?
    private let adUnitID: String
    
    // Test ID: ca-app-pub-3940256099942544/4411468910
    // Live ID varsayılan olarak kullanıcıdan gelen "geçiş" reklam ünitesi:
    init(adUnitID: String = "ca-app-pub-3565786409265176/1369779454") {
        self.adUnitID = adUnitID
        super.init()
        loadAd()
    }
    
    func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        }
    }
    
    func showAd() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let root = windowScene?.windows.first?.rootViewController
        
        if let ad = interstitial, let rootVC = root {
            ad.present(fromRootViewController: rootVC)
        } else {
            print("Ad wasn't ready")
            loadAd() // Try to reload if it wasn't ready
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        // Prepare next ad
        self.interstitial = nil
        loadAd()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        self.interstitial = nil
        loadAd()
    }
}
