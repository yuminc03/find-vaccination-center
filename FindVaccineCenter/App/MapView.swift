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
    var highlightLocation: CenterPreviewEntity?
    
    var locationError: VCError.LocationError?
    var searchText = ""
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case tapSearchButton
    case tapMarker(CenterPreviewEntity)
    
    case requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
    
    enum Delegate: Equatable {
      case tapViewMoreButton
      case tapNextButton(CenterPreviewEntity)
    }
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding: break
      case .delegate: break
      case .tapSearchButton:
        return .run { send in
          await send(.requestVaccination)
        }
        
      case let .tapMarker(location):
        state.highlightLocation = location
        
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
            state.entity.append($0.toEntity)
          }
        } else {
          searchedData.forEach {
            state.entity.append($0.toEntity)
          }
        }
        
        state.highlightLocation = state.entity.first
        guard let location = state.highlightLocation else { break }
        
      case let ._vaccinationResponse(.failure(error)):
        state.error = error
      }
      
      return .none
    }
  }
}

struct MapView: View {
  @Perception.Bindable private var store: StoreOf<MapCore>
  
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
        
        currentRegion = .init(
          center: .init(latitude: latitude, longitude: longitude),
          span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
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
          .shadow(color: Color.indigo, radius: 8)
          .scaleEffect(location == store.highlightLocation ? 1 : 0.8)
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
      ForEach(viewStore.entity) { location in
        if location == viewStore.highlightLocation {
          CenterPreviewView(entity: location) {
            store.send(.delegate(.tapViewMoreButton))
          } nextAction: {
            store.send(.delegate(.tapNextButton(location)))
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
