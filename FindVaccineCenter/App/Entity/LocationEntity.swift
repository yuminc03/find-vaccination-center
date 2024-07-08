import Foundation
import MapKit

struct LocationEntity: Equatable, Identifiable {
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
  
  static func == (lhs: LocationEntity, rhs: LocationEntity) -> Bool {
    return lhs.id == rhs.id
  }
}
