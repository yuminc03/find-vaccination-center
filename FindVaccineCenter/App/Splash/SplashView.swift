import SwiftUI

import ComposableArchitecture

struct SplashView: View {
  @Binding private var showSplashView: Bool
  
  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  
  @State private var loadingText = "Finding an Vaccination Center...".map { String($0) }
  @State private var showLoadingText = false
  @State private var timerSeconds = 0
  @State private var counter = 0
  @State private var loop = 0
  
  init(showSplashView: Binding<Bool>) {
    self._showSplashView = showSplashView
  }
  
  var body: some View {
    WithPerceptionTracking {
      ZStack {
        Color.white
          .ignoresSafeArea()
        
        Image(.logoTransparent)
          .resizable()
          .frame(width: 77, height: 124)
        
        loadingSection
      }
      .onAppear {
        showLoadingText.toggle()
      }
      .onReceive(timer) { _ in
        withAnimation(.spring()) {
          if counter == loadingText.count - 1 {
            counter = 0
            loop += 1
            
            if loop >= 2 {
              showSplashView = false
            }
          } else {
            counter += 1
          }
        }
      }
    }
  }
}

private extension SplashView {
  var loadingSection: some View {
    ZStack {
      if showLoadingText {
        HStack(spacing: 0) {
          ForEach(loadingText.indices, id: \.self) {
            Text(loadingText[$0])
              .font(.system(size: 24, weight: .bold))
              .foregroundColor(.blue100)
              .offset(y: counter == $0 ? -10 : 0)
          }
        }
        .transition(.scale.animation(.easeIn))
      }
    }
    .offset(y: 100)
  }
}

#Preview {
  SplashView(showSplashView: .constant(true))
}
