import SwiftUI
import MapKit

import ComposableArchitecture

@Reducer
struct MapCore {
  struct State: Equatable {
    let id = UUID()
    
    var vaccinations: VaccinationCenterEntity?
    var entity: [CenterPreviewEntity] = []
    var error: VCError?
    var highlightLocation: CenterPreviewEntity?
    
    var centerPreview: CenterPreviewCore.State?
    
    @BindingState var locationError: VCError.LocationError?
    @BindingState var searchText = ""
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case centerPreview(CenterPreviewCore.Action)
    case tapSearchButton
    case tapMarker(CenterPreviewEntity)
    
    case requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding: break
      case .centerPreview: break
      case let .centerPreview(.tapViewMoreButton): break
      case let .centerPreview(.tapNextButton): break
        
      case .tapSearchButton:
        return .run { send in
          await send(.requestVaccination)
        }
        
      case let .tapMarker(location):
        state.highlightLocation = location
        state.centerPreview = .init(entity: location)
        
      case .requestVaccination:
        state.error = nil
        return .run { send in
          let dto = try await repo.requestVaccinationCenter(dataCount: 30)
          await send(._vaccinationResponse(.success(dto)))
        } catch: { error, send in
          await send(._vaccinationResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationResponse(.success(dto)):
        let searchedData = dto.data.filter { $0.centerName.contains(state.searchText)
        }
        state.vaccinations = dto
        
        state.entity = []
        if searchedData.count == 0 {
          dto.data.forEach {
            state.entity.append(.init(
              name: $0.centerName,
              coordinate: CLLocationCoordinate2D(
                latitude: Double($0.lat) ?? 0,
                longitude: Double($0.lng) ?? 0
              ),
              address: $0.address
            ))
          }
        } else {
          searchedData.forEach {
            state.entity.append(
              .init(
                name: $0.centerName,
                coordinate: CLLocationCoordinate2D(
                  latitude: Double($0.lat) ?? 0,
                  longitude: Double($0.lng) ?? 0
                ),
                address: $0.address
              )
            )
          }
        }
        
        state.highlightLocation = state.entity.first
        guard let location = state.highlightLocation else { break }
        
        state.centerPreview = .init(entity: location)
        
      case let ._vaccinationResponse(.failure(error)):
        state.error = error
      }
      
      return .none
    }
    .ifLet(\.centerPreview, action: \.centerPreview) {
      CenterPreviewCore()
    }
  }
}

struct MapView: View {
  private let store: StoreOf<MapCore>
  @ObservedObject private var viewStore: ViewStoreOf<MapCore>
  
  @StateObject private var locationService = LocationAuthorityService.shared
  
  @State private var currentRegion = MKCoordinateRegion(
    center: .init(
      latitude: 37.4802547,
      longitude: 126.9742529
    ),
    span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
  )
  
  private var region: Binding<MKCoordinateRegion> {
    .init(
      get: { currentRegion },
      set: { newValue in
        DispatchQueue.main.async { currentRegion = newValue }
      }
    )
  }
  
  init(store: StoreOf<MapCore>) {
    self.store = store
    self.viewStore = .init(store, observe: { $0 })
  }
  
  var body: some View {
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
      store.send(.requestVaccination)
    }
    .onReceive(locationService.$currentLocation) {
      guard let latitude = $0?.coordinate.latitude,
            let longitude = $0?.coordinate.longitude
      else { return }
      
      currentRegion = .init(
        center: .init(latitude: latitude, longitude: longitude),
        span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
      )
    }
    .environmentObject(locationService)
  }
}

private extension MapView {
  var MapView: some View {
    Map(
      coordinateRegion: region,
      annotationItems: viewStore.entity
    ) { location in
      MapAnnotation(coordinate: location.coordinate) {
        MapAnnotationView()
          .shadow(color: Color.indigo, radius: 8)
          .scaleEffect(location == viewStore.highlightLocation ? 1 : 0.8)
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
        TextField("주소를 입력해주세요", text: viewStore.$searchText)
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
      ForEach(viewStore.entity) {
        if $0 == viewStore.highlightLocation {
          IfLetStore(store.scope(
            state: \.centerPreview,
            action: \.centerPreview
          )) {
            CenterPreviewView(store: $0)
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
}

#Preview {
  MapView(store: .init(initialState: MapCore.State()) {
    MapCore()
  })
}
