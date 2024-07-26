import Foundation

import ComposableArchitecture

struct DetailCore: Reducer {
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
