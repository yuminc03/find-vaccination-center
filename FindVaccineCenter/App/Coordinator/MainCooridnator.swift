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
  private let store: StoreOf<MainCoordinator>
  
  var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
      SwitchStore(screen) { screen in
        switch screen {
        case .map:
          CaseLet(
            \MainScreen.State.map,
             action: MainScreen.Action.map,
             then: AppView.init
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
