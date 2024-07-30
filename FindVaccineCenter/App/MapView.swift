import SwiftUI
import MapKit

import ComposableArchitecture

struct MapView: View {
  @Perception.Bindable private var store: StoreOf<MapCore>
  
  @StateObject private var locationService = LocationAuthorityService.shared
  
  private var region: Binding<MKCoordinateRegion> {
    .init(
      get: { store.mapRegion },
      set: { newValue in
        DispatchQueue.main.async { store.send(._setMapRegion(newValue)) }
      }
    )
  }
  
  init(store: StoreOf<MapCore>) {
    self.store = store
  }
  
  var body: some View {
    WithPerceptionTracking {
      ZStack {
        MapView
        
        VStack(spacing: 0) {
          SearchView
          
          Spacer()
          
          CenterPreview
        }
      }
      .toast(
        isPresented: $store.isErrorToastPresented,
        message: store.error?.errorDescription ?? "",
        duration: 5,
        alignment: .bottom
      )
      .onAppear {
        guard store.viewDidLoad == false else { return }
        
        locationService.initialize()
        store.send(._onAppear)
      }
      .onReceive(locationService.$currentLocation) {
        guard let latitude = $0?.coordinate.latitude,
              let longitude = $0?.coordinate.longitude
        else { return }
        
        store.send(._setMapRegion(.init(
          center: .init(latitude: latitude, longitude: longitude),
          span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )))
      }
      .onReceive(locationService.$authorizationStatus) {
        switch $0 {
        case .denied:
          store.send(._setError(.location(.denied)))
          
        case .restricted:
          store.send(._setError(.location(.restricted)))
          
        default: break
        }
      }
      .environmentObject(locationService)
    }
  }
}

private extension MapView {
  var MapView: some View {
    Map(
      coordinateRegion: region,
      annotationItems: store.entity
    ) { location in
      MapAnnotation(coordinate: location.coordinate) {
        MapAnnotationView()
          .scaleEffect(location == store.mapLocation ? 1 : 0.8)
          .onTapGesture {
            store.send(.tapMarker(location))
          }
      }
    }
    .ignoresSafeArea()
  }
  
  var SearchView: some View {
    VStack(spacing: 0) {
      HStack(spacing: 10) {
        Image(systemName: .systemImage(.magnifyingglass))
          .size(20)
        
        Text(store.searchText.isEmpty ? "주소를 입력해주세요" : store.searchText)
          .frame(maxWidth: .infinity, alignment: .leading)
          .if(store.searchText.isEmpty) {
            $0.foregroundColor(.gray200)
          } falseTransform: {
            $0.foregroundColor(.black)
          }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 15)
      .background(.white)
      .cornerRadius(10)
      .shadow(radius: 10)
      .padding(.horizontal, 16)
      .contentShape(RoundedRectangle(cornerRadius: 10))
      .onTapGesture {
        store.send(.tapSearchBar)
      }
      
      Spacer()
    }
  }
  
  var CenterPreview: some View {
    ZStack {
      ForEach(store.entity) { location in
        if location == store.mapLocation {
          CenterPreviewView(entity: .init(
            name: location.name,
            coordinate: location.coordinate,
            address: location.address
          )) {
            store.send(.tapViewMoreButton(location))
          } nextAction: {
            store.send(.tapNextButton)
          }
          .shadow(radius: 20)
          .padding([.horizontal, .bottom], 20)
          .frame(maxWidth: .infinity)
          .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
          ))
        }
      }
    }
  }
}

#Preview {
  MapView(store: .init(initialState: MapCore.State()) {
    MapCore()
  })
}
