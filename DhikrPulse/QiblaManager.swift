import Foundation
import CoreLocation
import Combine
import SwiftUI

class QiblaManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    
    // Kabe Koordinatları
    private let kaabaLatitude: Double = 21.422487
    private let kaabaLongitude: Double = 39.826206
    
    @Published var heading: Double = 0.0          // Cihazın Kuzeye göre açısı (0-360)
    @Published var qiblaDirection: Double = 0.0   // Kabe'nin Kuzeye göre açısı
    @Published var qiblaAngle: Double = 0.0       // Kabe yönüne dönülmesi gereken göreceli açı (0-360)
    @Published var error: Error?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        } else {
            requestPermission()
        }
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.startUpdating()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let bearing = calculateBearing(from: location.coordinate)
        DispatchQueue.main.async {
            self.qiblaDirection = bearing
            self.updateQiblaAngle()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            // Gerçek kuzey varsa onu, yoksa manyetik kuzeyi kullan
            self.heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            self.updateQiblaAngle()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    // MARK: - Calculations
    
    private func updateQiblaAngle() {
        // Cihazın açısı ile kıble açısı arasındaki fark.
        // Cihaz döndükçe pusulanın dönmesi gereken ters açıyı verir.
        var angle = qiblaDirection - heading
        if angle < 0 {
            angle += 360
        }
        self.qiblaAngle = angle
    }
    
    /// Kullanıcının konumuna göre Kabe'nin bulunması gereken yön açısını hesaplar
    private func calculateBearing(from coordinate: CLLocationCoordinate2D) -> Double {
        let lat1 = coordinate.latitude * .pi / 180.0
        let lon1 = coordinate.longitude * .pi / 180.0
        let lat2 = kaabaLatitude * .pi / 180.0
        let lon2 = kaabaLongitude * .pi / 180.0
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        let bearingRad = atan2(y, x)
        let bearingDeg = bearingRad * 180.0 / .pi
        
        return (bearingDeg + 360).truncatingRemainder(dividingBy: 360)
    }
}
