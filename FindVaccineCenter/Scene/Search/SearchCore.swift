import Foundation

import ComposableArchitecture

@Reducer
struct SearchCore {
  @ObservableState
  struct State: Equatable {
    let id = UUID()
    
    var searchText = ""
    var isErrorToastPresented = false
    
    var centerTotal = 0
    var vaccinations: VaccinationCenterEntity?
    var searchList = [SearchListItemEntity]()
    var recommendSearchList = [VaccinationCenterEntity.Vaccnination]()
    var error: VCError?
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    
    case tapBackButton
    case tapRowDeleteButton(SearchListItemEntity)
    case tapClearButton
    case tapSubmitButton
    case changeSearchText(String)
    case tapRecommendRow(Int)
    case tapSearchRow(SearchListItemEntity)
    
    case _onAppear
    case _requestVaccinationTotal
    case _vaccinationTotalResponse(Result<Int, VCError>)
    case _requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
    case _getSearchList
    case _saveSearchText(VaccinationCenterDetailEntity?)
    case _saveError(VCError)
    
    enum Delegate {
      case search(VaccinationCenterDetailEntity)
    }
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding: break
      case .delegate: break
      case .tapBackButton: break
      case let .tapRowDeleteButton(entity):
        for i in 0 ..< state.searchList.count {
          if state.searchList[i].centerName == entity.centerName {
            state.searchList.remove(at: i)
            break
          }
        }
        
        UDStorage.searchList = state.searchList.map { $0.toDTO }
        return .send(._getSearchList)
        
      case .tapClearButton:
        state.searchText = ""
        
      case .tapSubmitButton:
        return .send(._saveSearchText(nil))
        
      case let .changeSearchText(value):
        state.searchText = value
        guard let vaccinations = state.vaccinations?.data else { break }
        
        state.recommendSearchList = vaccinations.filter { $0.centerName.contains(value) }
        
      case let .tapRecommendRow(id):
        guard let item = state.recommendSearchList.filter({ $0.id == id }).first else {
          print("id: \(id)에 해당하는 센터를 찾지 못함")
          return .send(._saveError(.map(.unknown("\(id)에 해당하는 센터를 찾지 못함"))))
        }
        
        state.searchText = item.centerName
        return .send(._saveSearchText(item.toEntity))
        
      case let .tapSearchRow(entity):
        state.searchText = entity.centerName
        return .send(.changeSearchText(entity.centerName))
        
      case ._onAppear:
        return .run { send in
          await send(._requestVaccinationTotal)
          await send(._requestVaccination)
          await send(._getSearchList)
        }
        
      case ._requestVaccinationTotal:
        state.error = nil
        return .run { send in
          let dto = try await repo.requestVaccinationCenter()
          await send(._vaccinationTotalResponse(.success(dto.totalCount)))
        } catch: { error, send in
          await send(._vaccinationTotalResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationTotalResponse(.success(count)):
        state.centerTotal = count > 50 ? 50 : count
        
      case let ._vaccinationTotalResponse(.failure(error)):
        return .send(._saveError(error))
        
      case ._requestVaccination:
        state.error = nil
        return .run { [state] send in
          let dto = try await repo.requestVaccinationCenter(dataCount: state.centerTotal)
          await send(._vaccinationResponse(.success(dto)))
        } catch: { error, send in
          await send(._vaccinationResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationResponse(.success(dto)):
        state.vaccinations = dto
        
      case let ._vaccinationResponse(.failure(error)):
        return .send(._saveError(error))
        
      case ._getSearchList:
        guard let list = UDStorage.searchList else {
          state.searchList = []
          break
        }
        
        state.searchList = list.map{ $0.toEntity }
        
      case let ._saveSearchText(entity):
        if state.searchList.isEmpty {
          UDStorage.searchList = [.init(
            centerName: state.searchText,
            dateString: Date().toString(format: .dotDate)
          )]
        } else {
          guard state.searchList.map({ $0.centerName }).contains(state.searchText) == false
          else {
            return .send(.delegate(.search(
              entity ?? VaccinationCenterDetailEntity(
                name: state.searchText,
                coordinate: .init(latitude: 0, longitude: 0),
                address: "",
                facilityName: "",
                org: "",
                phoneNumber: "", 
                zipCode: ""
              )
            )))
          }
          
          state.searchList.append(.init(
            centerName: state.searchText,
            dateString: Date().toString(format: .dotDate)
          ))
          
          UDStorage.searchList = state.searchList.map { $0.toDTO }
        }
        
        return .run { [state] send in
          await send(._getSearchList)
          await send(.delegate(.search(
            entity ?? VaccinationCenterDetailEntity(
              name: state.searchText,
              coordinate: .init(latitude: 0, longitude: 0),
              address: "",
              facilityName: "",
              org: "",
              phoneNumber: "",
              zipCode: ""
            )
          )))
        }
        
      case let ._saveError(error):
        state.error = error
        state.isErrorToastPresented = true
      }
      
      return .none
    }
  }
}
