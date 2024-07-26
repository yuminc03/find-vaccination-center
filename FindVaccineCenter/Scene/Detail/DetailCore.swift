import Foundation

import ComposableArchitecture

@Reducer
struct DetailCore {
  @ObservableState
  struct State: Equatable {
    let id = UUID()
    let entity: VaccinationCenterDetailEntity
  }

  enum Action {
    case tapCloseButton
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .tapCloseButton: break
      }
      
      return .none
    }
  }
}
