import SwiftUI

import ComposableArchitecture

struct SearchCore: Reducer {
  struct State: Equatable {
    
  }
  
  enum Action {
    
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}

/// 병원 검색 화면
struct SearchView: View {
  private let store: StoreOf<SearchCore>
  @ObservedObject private var viewStore: ViewStoreOf<SearchCore>
  
  init(store: StoreOf<SearchCore>) {
    self.store = Store(initialState: .init()) { SearchCore() }
    self.viewStore = ViewStore(self.store, observe: { $0 })
  }
  
  var body: some View {
    Text("")
  }
}

#Preview {
  SearchView(store: .init(initialState: SearchCore.State()) {
    SearchCore()
  })
}
