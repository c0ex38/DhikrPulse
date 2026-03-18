import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        
        // Use UIApplication to resolve the window scene safely
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let rootViewController = windowScene?.windows.first?.rootViewController
        
        bannerView.rootViewController = rootViewController
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
