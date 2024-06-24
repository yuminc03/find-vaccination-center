//
//  RepresentedNaverMap.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/4/24.
//

import SwiftUI
import UIKit
import CoreLocation

import NMapsMap

struct RepresentedNaverMap: UIViewRepresentable {
  @Binding var locationError: VCError.LocationError?
  
  private let mapView: NMFNaverMapView = {
    let v = NMFNaverMapView(frame: .zero)
    v.mapView.positionMode = .direction
    v.mapView.isNightModeEnabled = true
    v.mapView.zoomLevel = 15
    v.showLocationButton = true
    v.showZoomControls = true
    v.showCompass = true
    v.showScaleBar = true
    return v
  }()

  func makeUIView(context: Context) -> NMFNaverMapView {
    mapView.mapView.addCameraDelegate(delegate: context.coordinator.self)
    mapView.mapView.touchDelegate = context.coordinator.self
    return mapView
  }
  
  func updateUIView(_ uiView: NMFNaverMapView, context: Context) { }
  
  func makeCoordinator() -> Cooridnator {
    return .init(parent: self)
  }
  
  
  final class Cooridnator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate, CLLocationManagerDelegate {
    private let parent: RepresentedNaverMap
    private var locationManager: CLLocationManager?
    private var cameraLocation: NMGLatLng = .init(lat: 37.35959299, lng: 127.10531600)

    init(parent: RepresentedNaverMap) {
      self.parent = parent
      super.init()
      
      getCurrentLocation()
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
      cameraLocation.lat = mapView.cameraPosition.target.lat
      cameraLocation.lng = mapView.cameraPosition.target.lng
      moveCamera()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      guard let location = locations.first else { return }
      
      cameraLocation.lat = location.coordinate.latitude
      cameraLocation.lng = location.coordinate.longitude
      moveCamera()
    }
    
    private func getCurrentLocation() {
      DispatchQueue.global().async { [weak self] in
        if CLLocationManager.locationServicesEnabled() {
          self?.locationManager = CLLocationManager()
          self?.locationManager?.delegate = self
          self?.checkLocationPermission()
        } else {
          self?.parent.locationError = .unAuthorized
        }
      }
    }
    
    private func checkLocationPermission() {
      guard let locationManager else { return }
      
      switch locationManager.authorizationStatus {
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
        
      case .restricted:
        parent.locationError = .restricted
        
      case .denied:
        parent.locationError = .denied
        
      case .authorizedAlways, .authorizedWhenInUse, .authorized:
        cameraLocation.lat = locationManager.location?.coordinate.latitude ?? 0.0
        cameraLocation.lng = locationManager.location?.coordinate.longitude ?? 0.0
        moveCamera()
        
      @unknown default:
        parent.locationError = .unknown(nil)
      }
    }
    
    private func moveCamera() {
      DispatchQueue.main.async {
        let cameraUpdate = NMFCameraUpdate(scrollTo: .init(lat: self.cameraLocation.lat, lng: self.cameraLocation.lng))
        cameraUpdate.animation = .linear
        self.parent.mapView.mapView.moveCamera(cameraUpdate)
      }
    }
  }
}
