import SwiftUI

import ComposableArchitecture

struct SearchCore: Reducer {
  struct State: Equatable {
    @BindingState var searchText = ""
    let searchList: [SearchListItemEntity] = [
      .init(
        centerName: "코로나19 중앙 예방접종센터",
        dateString: "24.07.10"
      ),
      .init(
        centerName: "코로나19 영남권역 예방접종센터",
        dateString: "24.07.10"
      ),
      .init(
        centerName: "코로나19 호남권역 예방접종센터",
        dateString: "24.07.10"
      ),
    ]
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case tapBackButton
    case tapRowDeleteButton
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .binding: break
      case .tapBackButton: break
      case .tapRowDeleteButton: break
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
      
      Separator
      
      SearchList
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
        store.send(.tapBackButton)
      } label: {
        Image(systemName: .systemImage(.backArrow))
          .size(20)
          .foregroundColor(.black)
      }
      TextField("주소를 입력해주세요", text: viewStore.$searchText)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(.white)
    }
  }
  
  var Separator: some View {
    VStack(spacing: 0) {
      Divider()
      Rectangle()
        .foregroundColor(.gray100)
        .frame(height: 10)
    }
  }
  
  var SearchList: some View {
    List {
      ForEach(viewStore.searchList) { data in
        listRow(data)
      }
    }
    .listStyle(.plain)
  }
  
  func listRow(_ data: SearchListItemEntity) -> some View {
    HStack(spacing: 20) {
      Image(systemName: .systemImage(.magnifyingglass))
      HStack(spacing: 5) {
        Text(data.centerName)
          .font(.body)
          .lineLimit(1)
        Spacer()
        Text(data.dateString)
          .font(.caption)
      }
      
      Button {
        store.send(.tapRowDeleteButton)
      } label: {
        Image(systemName: .systemImage(.xmark))
          .size(12)
      }
    }
  }
}
