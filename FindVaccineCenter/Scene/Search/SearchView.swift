import SwiftUI

import ComposableArchitecture

struct SearchCore: Reducer {
  struct State: Equatable {
    @BindingState var searchText = ""
    let searchList: [SearchListItemEntity] = [
      .init(
        centerName: "코로나19 중앙 예방접종센터",
        phoneNumber: "02-2260-7114",
        address: "서울특별시 중구 을지로 39길 29"
      ),
      .init(
        centerName: "코로나19 영남권역 예방접종센터",
        phoneNumber: "055-360-6701",
        address: "경상남도 양산시 물금읍 금오로 20"
      ),
      .init(
        centerName: "코로나19 호남권역 예방접종센터",
        phoneNumber: "062-220-3739",
        address: "광주광역시 동구 필문대로 365"
      ),
    ]
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
      Image(systemName: "magnifyingglass")
      VStack(alignment: .leading, spacing: 5) {
        Text(data.centerName)
          .font(.headline)
        Text(data.phoneNumber)
          .font(.caption)
        Text(data.address)
          .font(.footnote)
      }
      Spacer()
      Button {
        
      } label: {
        Image(systemName: "xmark")
          .size(12)
      }
    }
  }
}
