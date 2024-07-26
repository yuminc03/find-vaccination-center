import SwiftUI

/// 지도에 예방접종 센터 위치를 표시할 Marker
struct MapAnnotationView: View {
  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: .systemImage(.stethoscopeCircleFill))
        .size(30)
        .foregroundColor(.white)
        .padding(5)
        .background(.blue100)
        .clipShape(Circle())
      
      Triangle
    }
    .shadow(color: .gray500, radius: 8)
  }
}

private extension MapAnnotationView {
  var Triangle: some View {
    Path { path in
      path.move(to: .init(x: 0, y: 0))
      path.addLine(to: .init(x: 12, y: 0))
      path.addLine(to: .init(x: 6, y: 12))
      path.addLine(to: .init(x: 0, y: 0))
      path.closeSubpath()
    }
    .fill(.blue100)
    .frame(width: 12, height: 12)
    .offset(y: -2)
  }
}

#Preview {
  ZStack {
    Color.black
      .ignoresSafeArea()
    MapAnnotationView()
  }
}
