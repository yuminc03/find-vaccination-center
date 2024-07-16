import SwiftUI
import MapKit

import ComposableArchitecture

@Reducer
struct AppCore {
  struct State: Equatable {
    var vaccinations: VaccinationCenterEntity?
    var entity: [CenterDetailEntity] = []
    var error: VCError?
    
    @BindingState var locationError: VCError.LocationError?
    @BindingState var searchText = ""
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case didTapSearchButton
    case changeLocation(Double, Double)
    
    case requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding: break
        
      case .didTapSearchButton:
        return .run { send in
          await send(.requestVaccination)
        }
        
      case let .changeLocation(lat, lng): break
        
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
              address: $0.address,
              facilityName: $0.facilityName
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
                address: $0.address,
                facilityName: $0.facilityName
              )
            )
          }
        }
        
      case let ._vaccinationResponse(.failure(error)):
        state.error = error
      }
      
      return .none
    }
  }
}

struct AppView: View {
  private let store: StoreOf<AppCore>
  @ObservedObject private var viewStore: ViewStoreOf<AppCore>
  
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
  
  init(store: StoreOf<AppCore>) {
    self.store = store
    self.viewStore = .init(store, observe: { $0 })
  }
  
  var body: some View {
    ZStack {
      MapView
      
      SearchView
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

private extension AppView {
  var MapView: some View {
    Map(
      coordinateRegion: region,
      annotationItems: viewStore.entity
    ) { location in
      MapAnnotation(coordinate: location.coordinate) {
        MapAnnotationView()
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
          store.send(.didTapSearchButton)
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
}

#Preview {
  AppView(store: .init(initialState: AppCore.State()) {
    AppCore()
  })
}
