import SwiftUI

extension Image {
  /// 가로와 세로가 같은 이미지 크기를 설정
  func size(_ size: CGFloat) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: size, height: size)
  }
}
