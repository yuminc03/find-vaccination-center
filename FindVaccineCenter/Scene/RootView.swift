//
//  ContentView.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/2/24.
//

import SwiftUI

import ComposableArchitecture

struct RootCore: Reducer {
  struct State: Equatable {
    let id = UUID()
    @BindingState var locationError: Error.LocationError?
    @BindingState var searchText = ""
  }
  
  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}

struct RootView: View {
  private let store: StoreOf<RootCore>
  @ObservedObject private var viewStore: ViewStoreOf<RootCore>
  
  init(store: StoreOf<RootCore>) {
    self.store = store
    self.viewStore = .init(store, observe: { $0 })
  }
  
  var body: some View {
    ZStack {
      RepresentedNaverMap(locationError: viewStore.$locationError)
        .ignoresSafeArea()
      searchView
      CenterFlag()
    }
  }
}

#Preview {
  RootView(store: .init(initialState: RootCore.State()) {
    RootCore()
  })
}

private extension RootView {
  var searchView: some View {
    VStack {
      HStack(spacing: 10) {
        searchBar
      }
      .padding(.horizontal, 16)
      Spacer()
    }
  }
  
  var searchBar: some View {
    TextField("주소를 입력해주세요", text: viewStore.$searchText)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .shadow(radius: 10)
  }
  
}
