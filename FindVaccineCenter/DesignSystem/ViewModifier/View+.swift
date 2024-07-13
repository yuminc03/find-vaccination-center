import SwiftUI

extension View {
  func cornerRadius(_ radius: CGFloat) -> some View {
    self
      .clipShape(RoundedRectangle(cornerRadius: radius))
  }
}
