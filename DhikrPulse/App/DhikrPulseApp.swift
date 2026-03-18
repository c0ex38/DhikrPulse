import SwiftUI
import FirebaseCore
import UserNotifications
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    return true
  }
}

@main
struct DhikrPulseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dhikrViewModel = DhikrViewModel()
    @StateObject private var storeManager = StoreManager()
    @State private var showMainApp = false
    
    @AppStorage("has_seen_onboarding") private var hasSeenOnboarding = false
    @AppStorage("app_color_scheme") private var schemeType: Int = 0
    @AppStorage("app_lang") private var appLang: String = ""
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showMainApp {
                    if hasSeenOnboarding {
                        MainTabView()
                            .environmentObject(dhikrViewModel)
                            .environmentObject(storeManager)
                            .onAppear {
                                storeManager.dhikrViewModel = dhikrViewModel
                                NotificationManager.shared.clearBadge()
                            }
                    } else {
                        OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                            .environmentObject(dhikrViewModel)
                            .environmentObject(storeManager)
                    }
                } else {
                    SplashView(showMainApp: $showMainApp)
                }
            }
            .preferredColorScheme(AppColorScheme(rawValue: schemeType)?.colorScheme)
            .environment(\.locale, appLang.isEmpty ? .current : Locale(identifier: appLang))
        }
    }
}
