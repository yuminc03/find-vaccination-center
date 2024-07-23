import SwiftUI

import ComposableArchitecture
import TCACoordinators

@Reducer
struct MainScreen {
  enum State: Equatable, Identifiable {
    case map(AppCore.State)
    case search(SearchCore.State)
    case detail(DetailCore.State)
    
    var id: UUID {
      switch self {
      case let .map(state):
        return state.id
        
      case let .search(state):
        return state.id
        
      case let .detail(state):
        return state.id
      }
    }
  }
  
  enum Action {
    case map(AppCore.Action)
    case search(SearchCore.Action)
    case detail(DetailCore.Action)
  }
  
  var body: some ReducerOf<Self> {
    Scope(state: \.map, action: \.map) {
      AppCore()
    }
    Scope(state: \.search, action: \.search) {
      SearchCore()
    }
    Scope(state: \.detail, action: \.detail) {
      DetailCore()
    }
  }
}
