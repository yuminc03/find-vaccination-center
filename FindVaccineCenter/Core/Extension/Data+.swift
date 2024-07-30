import Foundation

extension Data {
  /// 네트워크 요청으로 받은 data를 정렬해서 print함
  var toPrittierJSON: String {
    guard let json = try? JSONSerialization.jsonObject(
      with: self, 
      options: .mutableContainers
    ) else {
      return "Data를 jsonObject로 바꾸는 것에 실패함"
    }
    
    guard let data = try? JSONSerialization.data(
      withJSONObject: json, 
      options: .prettyPrinted
    ) else {
      return "jsonObject를 prettyPrinted된 Data로 바꾸는데 실패함"
    }
    
    return String(data: data, encoding: .utf8) ?? "String is nil"
  }
}
