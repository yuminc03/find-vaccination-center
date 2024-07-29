import Foundation

struct VaccinationCenterEntity: Equatable {
  let currentCount: Int
  let data: [Vaccnination]
  let matchCount: Int
  let page: Int
  let perPage: Int
  let totalCount: Int
  
  struct Vaccnination: Equatable {
    /// 주소
    let address: String
    /// 예방 접종 센터명
    let centerName: String
    /// 예방 접종 센터 유형
    let centerType: String
    let createdAt: String
    /// 시설명
    let facilityName: String
    /// 예방 접종 센터 고유 식별자
    let id: Int
    /// 좌표(위도)
    let lat: String
    /// 좌표(경도)
    let lng: String
    /// 운영기관
    let org: String
    /// 사무실 전화번호
    let phoneNumber: String
    /// 시도명
    let sido: String
    /// 시군구
    let sigungu: String
    let updatedAt: String
    /// 우편번호
    let zipCode: String
  }
}

extension VaccinationCenterEntity.Vaccnination {
  var toEntity: VaccinationCenterDetailEntity {
    return .init(
      name: centerName,
      coordinate: .init(
        latitude: Double(lat) ?? 0,
        longitude: Double(lng) ?? 0
      ),
      address: address,
      facilityName: facilityName,
      org: org,
      phoneNumber: phoneNumber,
      zipCode: zipCode
    )
  }
}
