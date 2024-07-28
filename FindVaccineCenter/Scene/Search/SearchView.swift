import SwiftUI

import ComposableArchitecture

@Reducer
struct SearchCore {
  @ObservableState
  struct State: Equatable {
    let id = UUID()
    
    var searchText = ""
    var centerTotal = 0
    var vaccinations: VaccinationCenterEntity?
    var searchList = [SearchListItemEntity]()
    var recommendSearchList = [VaccinationCenterEntity.Vaccnination]()
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    
    case tapBackButton
    case tapRowDeleteButton(SearchListItemEntity)
    case tapClearButton
    case tapSubmitButton
    case changeSearchText(String)
    case tapRecommendRow(Int)
    
    case _onAppear
    case _requestVaccinationTotal
    case _vaccinationTotalResponse(Result<Int, VCError>)
    case _requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
    case _getSearchList
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    
    Reduce { state, action in
      switch action {
      case .binding: break
      case .tapBackButton: break
      case let .tapRowDeleteButton(entity):
        guard var searchList = UDStorage.searchList else { break }
        for i in searchList.indices {
          if searchList[i].toEntity == entity {
            searchList.remove(at: i)
          }
        }
        
        UDStorage.searchList = searchList
        return .send(._getSearchList)
        
      case .tapClearButton:
        state.searchText = ""
        
      case .tapSubmitButton:
        guard var searchList = UDStorage.searchList else {
          UDStorage.searchList = [.init(
            centerName: state.searchText,
            dateString: Date().toString(format: .dotDate)
          )]
          break
        }
        
        guard searchList.map({ $0.centerName }).contains(state.searchText) == false 
        else { break }
        
        searchList.append(.init(
          centerName: state.searchText,
          dateString: Date().toString(format: .dotDate)
        ))
        
        UDStorage.searchList = searchList
        return .send(._getSearchList)
        
      case let .changeSearchText(value):
        state.searchText = value
        guard let vaccinations = state.vaccinations?.data else { break }
        
        state.recommendSearchList = vaccinations.filter { $0.centerName.contains(value) }
        
      case let .tapRecommendRow(id):
        guard let item = state.recommendSearchList.filter({ $0.id == id }).first else {
          print("id: \(id)에 해당하는 센터를 찾지 못함")
          break
        }
        
        state.searchText = item.centerName
        
      case ._onAppear:
        return .run { send in
          await send(._requestVaccinationTotal)
          await send(._requestVaccination)
          await send(._getSearchList)
        }
        
      case ._requestVaccinationTotal:
        return .run { send in
          let dto = try await repo.requestVaccinationCenter()
          await send(._vaccinationTotalResponse(.success(dto.totalCount)))
        } catch: { error, send in
          await send(._vaccinationTotalResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationTotalResponse(.success(count)):
        state.centerTotal = count
        
      case let ._vaccinationTotalResponse(.failure(error)): break
      case ._requestVaccination:
        return .run { [state] send in
          let dto = try await repo.requestVaccinationCenter(dataCount: state.centerTotal)
          await send(._vaccinationResponse(.success(dto)))
        } catch: { error, send in
          await send(._vaccinationResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationResponse(.success(dto)):
        state.vaccinations = dto
        
      case let ._vaccinationResponse(.failure(error)): break
      case ._getSearchList:
        guard let list = UDStorage.searchList else { break }
        state.searchList = list.map{ $0.toEntity }
      }
      
      return .none
    }
  }
}

/// 병원 검색 화면
struct SearchView: View {
  @Perception.Bindable private var store: StoreOf<SearchCore>
  
  init(store: StoreOf<SearchCore>) {
    self.store = store
  }
  
  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        SearchBar
          .padding(.horizontal, 20)
        
        Separator
        
        SearchList
      }
      .navigationBarHidden(true)
      .onAppear {
        store.send(._onAppear)
      }
    }
  }
}

private extension SearchView {
  var SearchBar: some View {
    HStack(spacing: 0) {
      Button {
        store.send(.tapBackButton)
      } label: {
        Image(systemName: .systemImage(.backArrow))
          .size(20)
          .foregroundColor(.black)
      }
      
      TextField("주소를 입력해주세요", text: $store.searchText.sending(\.changeSearchText))
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .keyboardType(.webSearch)
        .onSubmit {
          store.send(.tapSubmitButton)
        }
      
      if store.searchText.isEmpty == false {
        Button {
          store.send(.tapClearButton)
        } label: {
          Image(systemName: .systemImage(.xmarkCircleFill))
            .size(20)
            .foregroundColor(.black)
        }
      }
    }
  }
  
  var Separator: some View {
    VStack(spacing: 0) {
      Divider()
      Rectangle()
        .foregroundColor(.gray100)
        .frame(height: 10)
    }
  }
  
  var SearchList: some View {
    List {
      if store.searchText.isEmpty {
        if store.searchList.isEmpty {
          Text("검색기록이 없습니다")
            .foregroundColor(.gray200)
            .font(.system(size: 16))
            .listRowSeparator(.hidden)
        } else {
          ForEach(store.searchList) {
            listRow($0)
          }
        }
      } else {
        if store.recommendSearchList.isEmpty {
          Text("추천 검색어가 없습니다")
            .foregroundColor(.gray200)
            .font(.system(size: 16))
            .listRowSeparator(.hidden)
        } else {
          ForEach(store.recommendSearchList, id: \.id) {
            recommendListRow($0)
          }
        }
      }
    }
    .listStyle(.plain)
  }
  
  private func recommendListRow(_ data: VaccinationCenterEntity.Vaccnination) -> some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: .systemImage(.locationFill))
        .size(15)
      VStack(spacing: 5) {
        Text(data.centerName)
          .font(.system(size: 16, weight: .bold))
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(data.facilityName)
          .font(.system(size: 12))
          .foregroundColor(.gray200)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(data.address)
          .font(.system(size: 14))
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      store.send(.tapRecommendRow(data.id))
    }
  }
  
  private func listRow(_ data: SearchListItemEntity) -> some View {
    HStack(spacing: 10) {
      Image(systemName: .systemImage(.magnifyingglass))
        .size(15)
      HStack(spacing: 5) {
        Text(data.centerName)
          .font(.system(size: 14))
          .lineLimit(1)
        Spacer()
        Text(data.dateString)
          .font(.system(size: 12))
          .foregroundColor(.gray300)
      }
      
      Button {
        store.send(.tapRowDeleteButton(data))
      } label: {
        Image(systemName: .systemImage(.xmark))
          .size(15)
      }
      .buttonStyle(.plain)
    }
    .contentShape(Rectangle())
  }
}

#Preview {
  SearchView(store: .init(initialState: SearchCore.State()) {
    SearchCore()
  })
}
