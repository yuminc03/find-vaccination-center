import SwiftUI

import ComposableArchitecture

/// 예방접종 센터 Marker를 눌렀을 때 이름과 주소 정보를 보여주는 View
struct CenterPreviewView: View {
  private let store: StoreOf<CenterPreviewCore>
  @ObservedObject private var viewStore: ViewStoreOf<CenterPreviewCore>
  
  init(store: StoreOf<CenterPreviewCore>) {
    self.store = store
    self.viewStore = .init(store, observe: { $0 })
  }
  
  var body: some View {
    HStack(spacing: 0) {
      TitleSection
      
      Spacer(minLength: 10)
      
      VStack(spacing: 10) {
        ViewMoreButton
        NextButton
      }
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(.ultraThinMaterial)
    )
  }
}

private extension CenterPreviewView {
  var TitleSection: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(viewStore.entity.name)
        .font(.system(size: 16, weight: .bold))
      Text(viewStore.entity.address)
        .font(.system(size: 14))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  var ViewMoreButton: some View {
    defaultButton(
      "View More",
      bgColor: .blue100,
      foregroundColor: .white
    ) {
      store.send(.tapViewMoreButton)
    }
    .frame(width: 120)
  }
  
  var NextButton: some View {
    defaultButton(
      "Next",
      bgColor: .gray,
      foregroundColor: .white
    ) {
      store.send(.tapNextButton)
    }
    .frame(width: 120)
  }
  
  func defaultButton(
    _ title: String,
    bgColor: Color,
    foregroundColor: Color, 
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(foregroundColor)
        .frame(maxWidth: .infinity)
        .frame(height: 35)
        .background(bgColor)
        .cornerRadius(10)
    }
  }
}

#Preview {
  ZStack {
    Color.black
      .ignoresSafeArea()
    CenterPreviewView(store: .init(initialState: CenterPreviewCore.State(entity: .dummy)) {
      CenterPreviewCore()
    })
  }
}
