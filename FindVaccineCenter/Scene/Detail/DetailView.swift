import SwiftUI
import MapKit

import ComposableArchitecture

struct DetailCore: Reducer {
  struct State: Equatable {
    
  }
  
  enum Action {
    case tapBackButton
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      return .none
    }
  }
}

/// 병원 상세 정보 화면
struct DetailView: View {
  private let store: StoreOf<DetailCore>
  @ObservedObject private var viewStore: ViewStoreOf<DetailCore>
  
  private var currentRegion = MKCoordinateRegion(
    center: .init(
      latitude: 37.35959299,
      longitude: 127.10531600
    ),
    span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
  )
  
  init(store: StoreOf<DetailCore>) {
    self.store = Store(initialState: .init()) { DetailCore() }
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  var body: some View {
    VStack(spacing: 0) {
      MapView
      
      BottomSheet
    }
    .VCNaviBar(title: "Test") {
      store.send(.tapBackButton)
    }
  }
}

#Preview {
  DetailView(store: .init(initialState: DetailCore.State()) {
    DetailCore()
  })
}

private extension DetailView {
  var MapView: some View {
    Map(coordinateRegion: .constant(currentRegion))
      .ignoresSafeArea()
      .frame(height: 300)
  }
  
  var BottomSheet: some View {
    VStack(spacing: 10) {
      
    }
    .frame(maxHeight: .infinity)
  }
}
