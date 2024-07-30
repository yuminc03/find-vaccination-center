import SwiftUI

/// 일정 시간이 지나면 사라지는 Toast
extension View {
  func toast(
    isPresented: Binding<Bool>,
    message: String,
    duration: Int,
    alignment: ToastAlignment
  ) -> some View {
    ZStack(
      alignment: alignment == .center ? .center : alignment == .top
           ? .top : .bottom
    ) {
      self
      VCToast(isPresented: isPresented, message: message, duration: duration)
    }
  }
}

enum ToastAlignment {
  case top
  case center
  case bottom
}

struct VCToast: View {
  @Binding private var isPresented: Bool
  private let message: String
  private let duration: Int
  
  init(isPresented: Binding<Bool>, message: String, duration: Int) {
    self._isPresented = isPresented
    self.message = message
    self.duration = duration
  }
  
  var body: some View {
    ZStack {
      if isPresented {
        toastView
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(duration)) {
              isPresented = false
            }
          }
      }
    }
    .animation(.easeInOut(duration: 0.5), value: isPresented)
  }
}

private extension VCToast {
  var toastView: some View {
    Text(message)
      .foregroundStyle(.white)
      .font(.system(size: 16))
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
      .background(.black)
      .clipShape(Capsule())
      .padding(.horizontal, 20)
      .padding(.vertical, 24)
  }
}

#Preview {
  VCToast(isPresented: .constant(true), message: "message", duration: 5)
}
