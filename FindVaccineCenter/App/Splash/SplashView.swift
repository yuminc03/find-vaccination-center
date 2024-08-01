import SwiftUI

import ComposableArchitecture

struct SplashView: View {
  @Perception.Bindable private var store: StoreOf<SplashCore>
  
  init(store: StoreOf<SplashCore>) {
    self.store = store
  }
  
  var body: some View {
    WithPerceptionTracking {
      ZStack {
        Color.white
          .ignoresSafeArea()
        
        loadingSection
      }
      .onAppear {
        store.send(.toggleShowLoadingText)
        store.send(._startTimer)
      }
      .onReceive(store.publisher.timerSeconds) { _ in
        store.send(._startAnimation, animation: .spring)
      }
      .onDisappear {
        store.send(._cancelTimer)
      }
    }
  }
}

private extension SplashView {
  var loadingSection: some View {
    ZStack {
      if store.showLoadingText {
        HStack(spacing: 0) {
          ForEach(store.loadingText.indices, id: \.self) {
            Text(store.loadingText[$0])
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.blue100)
              .offset(y: store.counter == $0 ? -5 : 0)
          }
        }
        .transition(.scale.animation(.easeIn))
      }
    }
  }
}

#Preview {
  SplashView(store: .init(initialState: SplashCore.State(showLaunchView: true)) {
    SplashCore()
  })
}
