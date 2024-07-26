import SwiftUI
import MapKit

import ComposableArchitecture

/// 병원 상세 정보 화면
struct DetailView: View {
  @Perception.Bindable private var store: StoreOf<DetailCore>
  
  @Environment(\.openURL) private var openURL
  
  init(store: StoreOf<DetailCore>) {
    self.store = store
  }
  
  var body: some View {
    WithPerceptionTracking {
      VStack(spacing: 0) {
        MapView
        
        BottomSheet
      }
      .ignoresSafeArea()
      .overlay(alignment: .topTrailing) {
        CloseButton
      }
    }
  }
}

private extension DetailView {
  var MapView: some View {
    Map(
      coordinateRegion: .constant(
        MKCoordinateRegion(
          center: store.entity.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      ),
      annotationItems: [store.entity]
    ) { location in
      MapAnnotation(coordinate: location.coordinate) {
        MapAnnotationView()
          .shadow(radius: 10)
      }
    }
    .allowsHitTesting(false)
    .frame(height: UIScreen.main.bounds.height / 2)
  }
  
  var BottomSheet: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(store.entity.name)
        .font(.system(size: 24, weight: .bold))
        .frame(maxWidth: .infinity, alignment: .leading)
      
      Text(store.entity.facilityName)
        .font(.system(size: 14))
        .foregroundColor(.gray400)
      
      centerLabel(
        "\(store.entity.address) (\(store.entity.zipCode))",
        image: .systemImage(.locationFill)
      )
      
      centerLabel(
        store.entity.org,
        image: .systemImage(.docTextMagnifyingglass)
      )
      
      Divider()
      
      if store.entity.phoneNumber.isEmpty == false {
        HStack(alignment: .top, spacing: 20) {
          centerLabel(
            store.entity.phoneNumber,
            image: .systemImage(.phoneFill)
          )
          
          Spacer()
          
          CallButton
        }
      }
      
      Spacer()
    }
    .foregroundColor(.black)
    .padding(20)
    .background(.white)
  }
  
  var CloseButton: some View {
    Button {
      store.send(.tapCloseButton)
    } label: {
      Image(systemName: .systemImage(.xmark))
        .size(16)
        .foregroundColor(.black)
        .padding(20)
        .background(.thinMaterial)
        .cornerRadius(10)
        .padding([.top, .trailing], 20)
    }
  }
  
  var CallButton: some View {
    Button {
      if let url = URL(string: "tel://\(store.entity.phoneNumber)") {
        openURL(url)
      }
    } label: {
      Image(systemName: .systemImage(.phoneCircleFill))
        .size(50)
        .foregroundColor(.green)
    }
  }
  
  func centerLabel(_ title: String, image: String) -> some View {
    Label {
      Text(title)
        .font(.system(size: 16))
        .foregroundColor(.black)
    } icon: {
      Image(systemName: image)
        .size(15)
        .foregroundColor(.blue100)
    }
  }
}

#Preview {
  DetailView(store: .init(initialState: DetailCore.State(entity: .dummy)) {
    DetailCore()
  })
}
