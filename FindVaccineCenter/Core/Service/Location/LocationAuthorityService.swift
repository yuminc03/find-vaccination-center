import Foundation
import CoreLocation

/// 권한 설정
final class LocationAuthorityService: NSObject, ObservableObject {
  let locationManager: CLLocationManager = {
    let v = CLLocationManager()
    v.desiredAccuracy = kCLLocationAccuracyBest
    return v
  }()
  
  @Published var authorizationStatus: CLAuthorizationStatus?
  @Published var currentLocation: CLLocation?
  
  static let shared = LocationAuthorityService()
  
  private override init() { }
  
  func initialize() {
    DispatchQueue.global().async { [weak self] in
      if CLLocationManager.locationServicesEnabled() {
        self?.locationManager.delegate = self
      } else {
        print("locationServices not enabled.")
      }
    }
  }
}

extension LocationAuthorityService: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
      
    case .restricted:
      break
      
    case .denied:
      break
      
    case .authorizedAlways, .authorizedWhenInUse:
      locationManager.requestLocation()
      
    @unknown default:
      break
    }
    
    authorizationStatus = manager.authorizationStatus
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    
    currentLocation = .init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    print("location didFailWithError: \(error.localizedDescription)")
  }
}
