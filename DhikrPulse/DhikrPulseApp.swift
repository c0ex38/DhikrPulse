import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
      // Request Notification Authorization
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
          if let error = error {
              print("Bildirim izni istenirken hata oluştu: \(error.localizedDescription)")
          } else {
              print("Bildirim izni durumu: \(granted)")
          }
      }
      
    return true
  }
}

@main
struct DhikrPulseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dhikrViewModel = DhikrViewModel()
    @StateObject private var storeManager = StoreManager()
    @State private var showMainApp = false
    
    var body: some Scene {
        WindowGroup {
            if showMainApp {
                MainTabView()
                    .environmentObject(dhikrViewModel)
                    .environmentObject(storeManager)
                    .onAppear {
                        storeManager.dhikrViewModel = dhikrViewModel
                    }
            } else {
                SplashView(showMainApp: $showMainApp)
            }
        }
    }
}
