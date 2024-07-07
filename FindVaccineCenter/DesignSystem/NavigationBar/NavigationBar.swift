import SwiftUI

/// Custom NavigationBar
struct NavigationBarModifier<L, C, R>: ViewModifier where L: View, C: View, R: View {
  private let leftView: (() -> L)?
  private let centerView: (() -> C)?
  private let rightView: (() -> R)?
  
  init(
    leftView: (() -> L)? = nil,
    centerView: (() -> C)? = nil,
    rightView: (() -> R)? = nil
  ) {
    self.leftView = leftView
    self.centerView = centerView
    self.rightView = rightView
  }
  
  func body(content: Content) -> some View {
    VStack {
      ZStack {
        HStack {
          leftView?()
          
          Spacer()
          
          rightView?()
        }
        .frame(height: 56)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        
        HStack {
          Spacer()
          
          centerView?()
          
          Spacer()
        }
      }
      .background {
        Color.white
          .ignoresSafeArea(.all, edges: .top)
      }
      
      content
      
      Spacer()
    }
    .navigationBarHidden(true)
  }
}

extension View {
  func VCNaviBar<L, C, R>(
    leftView: (() -> L)? = nil,
    centerView: (() -> C)? = nil,
    rightView: (() -> R)? = nil
  ) -> some View where C: View, L: View, R: View {
    modifier(NavigationBarModifier(
      leftView: leftView,
      centerView: centerView,
      rightView: rightView
    ))
  }
  
  func VCNaviBar(
    title: String,
    leftAction: @escaping () -> Void
  ) -> some View {
    modifier(NavigationBarModifier(leftView: {
      Button (action: leftAction) {
        Image(systemName: .systemImage(.backArrow))
          .size(20)
          .foregroundColor(.black)
      }
    }, centerView: {
      Text(title)
        .font(.headline)
    }, rightView: {
      EmptyView()
    }))
  }
}
