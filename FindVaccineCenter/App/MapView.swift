import SwiftUI
import MapKit

import ComposableArchitecture

@Reducer
struct MapCore {
  @ObservableState
  struct State: Equatable {
    let id = UUID()
    
    var vaccinations: VaccinationCenterEntity?
    var entity: [VaccinationCenterDetailEntity] = []
    var error: VCError?
    var mapLocation: VaccinationCenterDetailEntity?
    var viewDidLoad = false
    
    var locationError: VCError.LocationError?
    var searchText = ""
    var mapRegion = MKCoordinateRegion(
      center: .init(
        latitude: 37.4802547,
        longitude: 126.9742529
      ),
      span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case tapSearchButton
    case tapMarker(VaccinationCenterDetailEntity)
    case tapViewMoreButton(VaccinationCenterDetailEntity)
    case tapNextButton
    
    case _requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
    case _updateCurrentLocation
    case _updateMapRegion(VaccinationCenterDetailEntity)
    case _setMapRegion(MKCoordinateRegion)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding: break
      case .tapViewMoreButton: break
      case .tapSearchButton:
        return .send(._requestVaccination)
        
      case let .tapMarker(location):
        return .send(._updateMapRegion(location))
        
      case .tapNextButton:
        guard let index = state.entity.firstIndex(where: { $0 == state.mapLocation }) else {
          print("현재 위치를 Locations 안에서 찾을 수 없음")
          break
        }
        
        let nextIndex = index + 1
        guard state.entity.indices.contains(nextIndex) else {
          guard let firstLocation = state.entity.first else {
            print("Locations가 비어있음")
            break
          }
          
          return .send(._updateMapRegion(firstLocation))
        }
        
        return .send(._updateMapRegion(state.entity[nextIndex]))
        
      case ._requestVaccination:
        state.error = nil
        return .run { send in
          let dto = try await repo.requestVaccinationCenter(dataCount: 30)
          await send(._vaccinationResponse(.success(dto)))
        } catch: { error, send in
          await send(._vaccinationResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationResponse(.success(dto)):
        state.vaccinations = dto
        state.entity = []
        let data = dto.data.filter { $0.centerName.contains(state.searchText) }
        if data.count == 0 {
          dto.data.forEach {
            state.entity.append($0.toEntity)
          }
        } else {
          data.forEach {
            state.entity.append($0.toEntity)
          }
        }
        
        guard let region = state.entity.first else { break }
        
        if state.viewDidLoad {
          return .send(._updateMapRegion(region))
        } else {
          state.viewDidLoad = true
          return .run { send in
            try await Task.sleep(seconds: 3.0)
            await send(._updateMapRegion(region))
          }
        }
        
      case let ._vaccinationResponse(.failure(error)):
        state.error = error
        
      case ._updateCurrentLocation:
        guard let region = state.entity.first else { break }
        
        if state.viewDidLoad {
          return .send(._updateMapRegion(region))
        } else {
          state.viewDidLoad = true
          return .run { send in
            try await Task.sleep(seconds: 3.0)
            await send(._updateMapRegion(region))
          }
        }
        
      case let ._updateMapRegion(location):
        state.mapLocation = location
        state.mapRegion = .init(
          center: .init(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
          ),
          span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
      case let ._setMapRegion(value):
        state.mapRegion = value
      }
      
      return .none
    }
  }
}

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
      .onAppear {
        locationService.initialize()
        store.send(._requestVaccination)
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
        TextField("주소를 입력해주세요", text: $store.searchText)
          .padding(.horizontal, 20)
          .padding(.vertical, 15)
          .background(.white)
          .clipShape(RoundedRectangle(cornerRadius: 10))
          .shadow(radius: 10)
          .foregroundColor(.black)
        
        Button {
          store.send(.tapSearchButton)
        } label: {
          Image(systemName: .systemImage(.magnifyingglass))
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(.white)
            .padding(15)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
        }
      }
      .padding(.horizontal, 16)
      
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
