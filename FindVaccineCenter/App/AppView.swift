//
//  ContentView.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/2/24.
//

import SwiftUI
import MapKit

import ComposableArchitecture

struct AppCore: Reducer {
  struct State: Equatable {
    let id = UUID()
    var vaccninations: VaccinationCenterEntity?
    var error: VCError?
    @BindingState var locationError: VCError.LocationError?
    @BindingState var searchText = ""
  }
  
  private let repo = VaccinationCenterRepository()
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case didTapSearchButton
    
    case requestVaccination
    case _vaccinationResponse(Result<VaccinationCenterEntity, VCError>)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        break
        
      case .didTapSearchButton:
        return .run { send in
          await send(.requestVaccination)
        }
        
      case .requestVaccination:
        state.error = nil
        return .run { send in
          let dto = try await repo.requestVaccinationCenter()
          await send(._vaccinationResponse(.success(dto)))
        } catch: { error, send in
          await send(._vaccinationResponse(.failure(error.toVCError)))
        }
        
      case let ._vaccinationResponse(.success(dto)):
        state.vaccninations = dto
        
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
  @State var region = MKCoordinateRegion(
    center: .init(latitude: 37.35959299, longitude: 127.10531600),
    span: .init(latitudeDelta: 0.5, longitudeDelta: 0.5)
  )
  
  init(store: StoreOf<AppCore>) {
    self.store = store
    self.viewStore = .init(store, observe: { $0 })
  }
  
  var body: some View {
    ZStack {
      RepresentedNaverMap(locationError: viewStore.$locationError)
        .ignoresSafeArea()
      searchView
      CenterFlag()
    }
    .onAppear {
      AuthorityService.requestLocationPermission()
    }
  }
}

#Preview {
  AppView(store: .init(initialState: AppCore.State()) {
    AppCore()
  })
}

private extension AppView {
  var searchView: some View {
    VStack {
      HStack(spacing: 10) {
        searchBar
        searchButton
      }
      .padding(.horizontal, 16)
      Spacer()
    }
  }
  
  var searchBar: some View {
    TextField("주소를 입력해주세요", text: viewStore.$searchText)
      .padding(.horizontal, 20)
      .padding(.vertical, 15)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .shadow(radius: 10)
  }
  
  var searchButton: some View {
    Button {
      store.send(.didTapSearchButton)
    } label: {
      Image(systemName: "magnifyingglass")
        .resizable()
        .frame(width: 20, height: 20)
        .foregroundColor(.white)
        .padding(15)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 10)
    }
  }
  
}
