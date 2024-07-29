import Foundation
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
    case tapSearchBar
    case tapMarker(VaccinationCenterDetailEntity)
    case tapViewMoreButton(VaccinationCenterDetailEntity)
    case tapNextButton
    
    case _requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
    case _updateMapRegion(VaccinationCenterDetailEntity)
    case _setMapRegion(MKCoordinateRegion)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding: break
      case .tapViewMoreButton: break
      case .tapSearchBar: break
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
            try await Task.sleep(seconds: 1.0)
            await send(._updateMapRegion(region))
          }
        }
        
      case let ._vaccinationResponse(.failure(error)):
        state.error = error
        
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
