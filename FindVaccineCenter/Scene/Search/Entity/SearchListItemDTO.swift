import Foundation

struct SearchListItemDTO: Codable {
  /// 예방 접종 센터명
  let centerName: String
  /// 검색한 날짜
  let dateString: String
}

extension SearchListItemDTO {
  var toEntity: SearchListItemEntity {
    return .init(centerName: centerName, dateString: dateString)
  }
}
