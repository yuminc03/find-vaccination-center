import Foundation

/// 예방접종센터 위치정보 API
///
/// API 참고 URL: https://www.data.go.kr/data/15077586/openapi.do#tab_layer_prcuse_exam
struct VaccinationCenterResponseDTO: Decodable {
  let currentCount: Int
  let data: [Vaccnination]
  let matchCount: Int
  let page: Int
  let perPage: Int
  let totalCount: Int
  
  struct Vaccnination: Decodable {
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

extension VaccinationCenterResponseDTO {
  var toEntity: VaccinationCenterEntity {
    .init(
      currentCount: currentCount,
      data: data.map { $0.toEntity },
      matchCount: matchCount,
      page: page,
      perPage: perPage, 
      totalCount: totalCount
    )
  }
}

extension VaccinationCenterResponseDTO.Vaccnination {
  var toEntity: VaccinationCenterEntity.Vaccnination {
    .init(
      address: address,
      centerName: centerName,
      centerType: centerType,
      createdAt: createdAt,
      facilityName: facilityName,
      id: id,
      lat: lat,
      lng: lng,
      org: org,
      phoneNumber: phoneNumber,
      sido: sido,
      sigungu: sigungu, 
      updatedAt: updatedAt,
      zipCode: zipCode
    )
  }
}
