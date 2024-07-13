import Foundation
import MapKit

/// 예방접종 센터 상세 화면 데이터
struct CenterDetailEntity: Identifiable, Equatable {
  /// 예방 접종 센터명
  let name: String
  /// 위치
  let coordinate: CLLocationCoordinate2D
  /// 주소
  let address: String
  /// 시설명
  let facilityName: String
  
  var id: String {
    return name + address
  }
  
  static func == (lhs: CenterDetailEntity, rhs: CenterDetailEntity) -> Bool {
    return lhs.id == rhs.id
  }
  
  static let dummy = CenterDetailEntity(
    name: "코로나19 중앙 예방접종센터",
    coordinate: .init(latitude: 37.567817, longitude: 127.004501),
    address: "서울특별시 중구 을지로 39길 29",
    facilityName: "국립중앙의료원 D동"
  )
}
