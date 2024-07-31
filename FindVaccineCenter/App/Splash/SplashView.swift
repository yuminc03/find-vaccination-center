import SwiftUI

import ComposableArchitecture

@Reducer
struct SplashCore {
  struct State: Equatable {
    var loadingText = "Finding an Vaccination Center...".map { String($0) }
    var showLoadingText = false
    var counter = 0
    var loop = 0
  }
  
  enum Action {
    
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      }
      
      return .none
    }
  }
}

struct SplashView: View {
  @Perception.Bindable private var store: StoreOf<SplashCore>
  
  init(store: StoreOf<SplashCore>) {
    self.store = store
  }
  
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  SplashView(store: .init(initialState: SplashCore.State()) {
    SplashCore()
  })
}
