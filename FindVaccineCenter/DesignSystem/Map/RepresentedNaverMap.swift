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

  func makeUIView(context: Context) -> NMFNaverMapView {
    let mapView = NMFNaverMapView(frame: .zero)
    mapView.mapView.positionMode = .direction
    mapView.mapView.isNightModeEnabled = true
    mapView.mapView.zoomLevel = 15
    mapView.showLocationButton = true
    mapView.showZoomControls = true
    mapView.showCompass = true
    mapView.showScaleBar = true
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
    private var cameraLocation: (lat: Double, lng: Double)?

    init(parent: RepresentedNaverMap) {
      self.parent = parent
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
      cameraLocation?.lat = mapView.cameraPosition.target.lat
      cameraLocation?.lng = mapView.cameraPosition.target.lng
    }
    
    private func getCurrentLocation() {
      if CLLocationManager.locationServicesEnabled() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        checkLocationPermission()
      } else {
        parent.locationError = .unAuthorized
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
        cameraLocation?.lat = locationManager.location?.coordinate.latitude ?? 0.0
        cameraLocation?.lng = locationManager.location?.coordinate.longitude ?? 0.0
        
      @unknown default:
        parent.locationError = .unknown
      }
    }
  }
}
