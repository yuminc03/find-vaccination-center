import SwiftUI
import MapKit

import ComposableArchitecture

struct DetailCore: Reducer {
  struct State: Equatable {
    let entity: CenterDetailEntity
  }
  
  enum Action {
    case delegate(Delegate)
    case tapBackButton
    
    enum Delegate {
      case back
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate: break
      case .tapBackButton:
        return .run { send in
          await send(.delegate(.back))
        }
      }
      
      return .none
    }
  }
}

/// 병원 상세 정보 화면
struct DetailView: View {
  private let store: StoreOf<DetailCore>
  @ObservedObject private var viewStore: ViewStoreOf<DetailCore>
  
  init(store: StoreOf<DetailCore>) {
    self.store = store
    self.viewStore = ViewStore(store, observe: { $0 })
  }
  
  var body: some View {
    VStack(spacing: 0) {
      MapView
      
      BottomSheet
    }
    .VCNaviBar(title: "\(viewStore.entity.name)") {
      store.send(.tapBackButton)
    }
  }
}

private extension DetailView {
  var MapView: some View {
    Map(
      coordinateRegion: .constant(
        MKCoordinateRegion(
          center: viewStore.entity.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      ),
      annotationItems: [viewStore.entity]
    ) { location in
      MapAnnotation(coordinate: location.coordinate) {
        MapAnnotationView()
          .shadow(radius: 10)
      }
    }
    .allowsHitTesting(false)
    .ignoresSafeArea()
  }
  
  var BottomSheet: some View {
    VStack(spacing: 20) {
      RoundedRectangle(cornerRadius: 5)
        .fill(.gray300)
        .frame(width: 50, height: 5)
        .padding(.top, 20)
      
      VStack(alignment: .leading, spacing: 10) {
        Text(viewStore.entity.name)
          .font(.system(size: 24))
          .frame(maxWidth: .infinity, alignment: .leading)
        Text(viewStore.entity.facilityName)
          .font(.system(size: 14))
        Text(viewStore.entity.address)
          .font(.system(size: 16))
      }
      .foregroundColor(.black)
      
      Spacer()
    }
    .padding(.horizontal, 20)
    .frame(height: 200)
    .background(.white)
    .cornerRadius(20, corners: [.topLeft, .topRight])
    .shadow(radius: 10, y: -18)
  }
}

#Preview {
  DetailView(store: .init(initialState: DetailCore.State(entity: .dummy)) {
    DetailCore()
  })
}
