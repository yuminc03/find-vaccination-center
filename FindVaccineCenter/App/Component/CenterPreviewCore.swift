import ComposableArchitecture

@Reducer
struct CenterPreviewCore {
  struct State: Equatable {
    let entity: CenterPreviewEntity
  }
  
  enum Action {
    case tapViewMoreButton
    case tapNextButton
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .tapViewMoreButton: break
      case .tapNextButton: break
      }
      return .none
    }
  }
}
