import SwiftUI

/// 지도에 예방접종 센터 위치를 표시할 Marker
struct MapAnnotationView: View {
  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: "stethoscope.circle.fill")
        .size(30)
        .foregroundColor(.white)
        .padding(5)
        .background(.blue100)
        .clipShape(Circle())
      
      Image(systemName: "triangleshape.fill")
        .size(10)
        .foregroundColor(.blue100)
        .rotationEffect(.init(degrees: 180))
        .offset(y: -2)
        .padding(.bottom, 40)
    }
  }
}

#Preview {
  ZStack {
    Color.black
      .ignoresSafeArea()
    MapAnnotationView()
  }
}