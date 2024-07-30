import SwiftUI

import TCACoordinators
import ComposableArchitecture

@Reducer
struct MainCoordinator {
  struct State: Equatable {
    static let initialState = State(routes: [.root(.map(.init()), embedInNavigationView: true)])
    var routes: IdentifiedArrayOf<Route<MainScreen.State>>
  }
  
  enum Action {
    case router(IdentifiedRouterActionOf<MainScreen>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        // MARK: - 지도 화면
      case let .router(.routeAction(id: _, action: .map(.tapViewMoreButton(location)))):
        state.routes.presentSheet(.detail(.init(entity: location)))
        
      case .router(.routeAction(id: _, action: .map(.tapSearchBar))):
        state.routes.push(.search(.init()))
        
        // MARK: - 예방접종 센터 상세 화면
      case .router(.routeAction(id: _, action: .detail(.tapCloseButton))):
        state.routes.dismiss()
        
        // MARK: - 검색 화면
      case .router(.routeAction(id: _, action: .search(.tapBackButton))):
        state.routes.goBack()
        
      case let .router(.routeAction(id: _, action: .search(.delegate(.search(entity))))):
        state.routes.findAndMutate(/MainScreen.State.map) { subState in
          subState.searchText = entity.name
          if entity.address.isEmpty {
            guard let index = subState.entity.firstIndex(where: { $0.name == entity.name }) else {
              print("\(entity.name)을 찾을 수 없음")
              return
            }
            
            let location = subState.entity[index]
            subState.mapLocation = location
            subState.mapRegion = .init(
              center: location.coordinate,
              span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
          } else {
            subState.mapLocation = entity
            subState.mapRegion = .init(
              center: entity.coordinate,
              span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
          }
        }
        state.routes.goBack()
        
      default: break
      }
      
      return .none
    }
    .forEachRoute(\.routes, action: \.router) {
      MainScreen()
    }
  }
}

struct MainCoordinatorView: View {
  let store: StoreOf<MainCoordinator>
  
  var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
      SwitchStore(screen) { screen in
        switch screen {
        case .map:
          CaseLet(
            \MainScreen.State.map,
             action: MainScreen.Action.map,
             then: MapView.init
          )
          
        case .search:
          CaseLet(
            \MainScreen.State.search,
             action: MainScreen.Action.search,
             then: SearchView.init
          )
          
        case .detail:
          CaseLet(
            \MainScreen.State.detail,
             action: MainScreen.Action.detail,
             then: DetailView.init
          )
        }
      }
    }
  }
}
