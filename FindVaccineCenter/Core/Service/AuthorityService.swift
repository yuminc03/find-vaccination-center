//
//  AuthorityService.swift
//  FindVaccineCenter
//
//  Created by LS-NOTE-00106 on 6/24/24.
//

import Foundation

import NMapsMap

/// 권한 설정
final class AuthorityService {
  static let locationManager: CLLocationManager = {
    let v = CLLocationManager()
    v.desiredAccuracy = kCLLocationAccuracyKilometer
    return v
  }()
  
  /// 위치 접근 허용
  static func requestLocationPermission() {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
      
    case .restricted:
      break
      
    case .denied:
      break
      
    case .authorizedAlways, .authorizedWhenInUse, .authorized:
      locationManager.requestLocation()
      
    @unknown default:
      break
    }
  }
}
