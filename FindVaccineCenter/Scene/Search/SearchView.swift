import SwiftUI

import ComposableArchitecture

struct SearchCore: Reducer {
  struct State: Equatable {
    @BindingState var searchText = ""
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .binding: break
        
        
      }
      
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
    VStack(spacing: 0) {
      SearchBar
        .padding(.horizontal, 20)
    }
  }
}

#Preview {
  SearchView(store: .init(initialState: SearchCore.State()) {
    SearchCore()
  })
}

private extension SearchView {
  var SearchBar: some View {
    HStack(spacing: 0) {
      Button {
        
      } label: {
        Image(systemName: "chevron.backward")
          .size(20)
          .foregroundColor(.black)
      }
      TextField("주소를 입력해주세요", text: viewStore.$searchText)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(.white)
    }
  }
}
