import SwiftUI

import ComposableArchitecture

/// 병원 검색 화면
struct SearchView: View {
  @Perception.Bindable private var store: StoreOf<SearchCore>
  
  init(store: StoreOf<SearchCore>) {
    self.store = store
  }
  
  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        SearchBar
          .padding(.horizontal, 20)
        
        Separator
        
        SearchList
      }
      .toast(
        isPresented: $store.isErrorToastPresented,
        message: store.error?.errorDescription ?? "",
        duration: 5,
        alignment: .bottom
      )
      .navigationBarHidden(true)
      .onAppear {
        store.send(._onAppear)
      }
    }
  }
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
      
      TextField("주소를 입력해주세요", text: $store.searchText.sending(\.changeSearchText))
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .keyboardType(.webSearch)
        .onSubmit {
          store.send(.tapSubmitButton)
        }
      
      if store.searchText.isEmpty == false {
        Button {
          store.send(.tapClearButton)
        } label: {
          Image(systemName: .systemImage(.xmarkCircleFill))
            .size(20)
            .foregroundColor(.black)
        }
      }
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
      if store.searchText.isEmpty {
        if store.searchList.isEmpty {
          Text("검색기록이 없습니다")
            .foregroundColor(.gray200)
            .font(.system(size: 16))
            .listRowSeparator(.hidden)
        } else {
          ForEach(store.searchList) {
            listRow($0)
          }
        }
      } else {
        if store.recommendSearchList.isEmpty {
          Text("추천 검색어가 없습니다")
            .foregroundColor(.gray200)
            .font(.system(size: 16))
            .listRowSeparator(.hidden)
        } else {
          ForEach(store.recommendSearchList, id: \.id) {
            recommendListRow($0)
          }
        }
      }
    }
    .listStyle(.plain)
  }
  
  private func recommendListRow(_ data: VaccinationCenterEntity.Vaccnination) -> some View {
    HStack(alignment: .top, spacing: 10) {
      Image(systemName: .systemImage(.locationFill))
        .size(15)
      VStack(spacing: 5) {
        Text(data.centerName)
          .font(.system(size: 16, weight: .bold))
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(data.facilityName)
          .font(.system(size: 12))
          .foregroundColor(.gray200)
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(data.address)
          .font(.system(size: 14))
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      store.send(.tapRecommendRow(data.id))
    }
  }
  
  private func listRow(_ data: SearchListItemEntity) -> some View {
    HStack(spacing: 10) {
      HStack(spacing: 10) {
        Image(systemName: .systemImage(.magnifyingglass))
          .size(15)
        
        HStack(spacing: 5) {
          Text(data.centerName)
            .font(.system(size: 14))
            .lineLimit(1)
          Spacer()
          Text(data.dateString)
            .font(.system(size: 12))
            .foregroundColor(.gray300)
        }
      }
      .contentShape(Rectangle())
      .onTapGesture {
        store.send(.tapSearchRow(data))
      }
      
      Button {
        store.send(.tapRowDeleteButton(data))
      } label: {
        Image(systemName: .systemImage(.xmark))
          .size(15)
      }
    }
  }
}

#Preview {
  SearchView(store: .init(initialState: SearchCore.State()) {
    SearchCore()
  })
}
