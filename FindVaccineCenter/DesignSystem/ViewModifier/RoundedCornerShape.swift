import SwiftUI

/// View CornerRaidus를 일부 모서리에만 줄 때 사용함
struct RoundedCornerShape: Shape {
  private let radius: CGFloat
  private let corners: UIRectCorner
  
  init(radius: CGFloat, corners: UIRectCorner) {
    self.radius = radius
    self.corners = corners
  }

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCornerShape(radius: radius, corners: corners))
  }
}
