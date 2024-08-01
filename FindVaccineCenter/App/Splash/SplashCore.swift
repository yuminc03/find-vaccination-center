import Foundation

import ComposableArchitecture

@Reducer
struct SplashCore {
  @ObservableState
  struct State: Equatable {
    var showLaunchView: Bool
    var loadingText = "Finding an Vaccination Center...".map { String($0) }
    var showLoadingText = false
    var timerSeconds = 0
    var counter = 0
    var loop = 0
  }
  
  enum Action {
    case toggleShowLoadingText
    
    case _startTimer
    case _timerTicked
    case _cancelTimer
    case _startAnimation
  }
  
  private enum CancelID {
    case timer
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .toggleShowLoadingText:
        state.showLoadingText.toggle()
        
      case ._startTimer:
        return .run { send in
          while true {
            try await Task.sleep(seconds: 0.1)
            await send(._timerTicked)
          }
        }
        .cancellable(id: CancelID.timer)
        
      case ._timerTicked:
        state.timerSeconds += 1
        
      case ._cancelTimer:
        return .cancel(id: CancelID.timer)
        
      case ._startAnimation:
        if state.counter == state.loadingText.count - 1 {
          state.counter = 0
          state.loop += 1
          
          if state.loop >= 2 {
            state.showLaunchView = false
          }
        } else {
          state.counter += 1
        }
      }
      
      return .none
    }
  }
}
