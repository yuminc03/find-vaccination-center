import Foundation

/// SF Symbols 이미지를 편하게 사용하기 위함
enum SystemImage: String {
  case backArrow = "chevron.backward"
  case magnifyingglass
  case xmark
}

extension String {
  static func systemImage(_ name: SystemImage) -> String {
    return name.rawValue
  }
}
