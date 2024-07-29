import SwiftUI

extension View {
  func cornerRadius(_ radius: CGFloat) -> some View {
    self
      .clipShape(RoundedRectangle(cornerRadius: radius))
  }
}
  
extension View {
  /**
   조건에 따라서 분기를 해줄 때 사용함
   ```
   Text("Text")
     .if(store.searchText.isEmpty) {
       $0.foregroundColor(.gray200)
     }
   ```
   */
  func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
    Group {
      if condition { transform(self) }
      else { self }
    }
  }
  
  /**
   조건에 따라서 분기를 해줄 때 사용함
   ```
   Text("Text")
     .if(store.searchText.isEmpty) {
       $0.foregroundColor(.gray200)
     } falseTransform: {
       $0.foregroundColor(.gray500)
     }
   ```
   */
  func `if`<T: View>(_ condition: Bool, trueTransform: (Self) -> T, falseTransform: (Self) -> T) -> some View {
    Group {
      if condition { trueTransform(self) }
      else { falseTransform(self) }
    }
  }
}
