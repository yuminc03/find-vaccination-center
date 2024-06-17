import Foundation

extension Dictionary {
  static var authorization: [String: String] {
    return ["Authorization": Constants.apiAuthKey]
  }
}
