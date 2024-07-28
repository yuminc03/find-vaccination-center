import Foundation

enum DateFormat: String {
  /// 05. 16.
  case dotDate = "MM. dd."
}

extension Date {
  func toString(format: DateFormat) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format.rawValue
    return dateFormatter.string(from: self)
  }
}
