import Foundation

/// 검색 결과 리스트에 표현될 병원 정보
struct SearchListItemEntity: Equatable, Identifiable {
  let id = UUID()
  /// 예방 접종 센터명
  let centerName: String
  /// 사무실 전화번호
  let phoneNumber: String
  /// 주소
  let address: String
}
