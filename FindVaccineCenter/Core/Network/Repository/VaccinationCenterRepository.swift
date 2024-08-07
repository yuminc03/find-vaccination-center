import Foundation

final class VaccinationCenterRepository {
  enum ReturnType: String {
    case xml = "XML"
    case json = "JSON"
  }
  
  private let networkManager = NetworkManager()

  func requestVaccinationCenter(
    pageIndex: Int = 1,
    dataCount: Int = 10,
    returnType: ReturnType = .json
  ) async throws -> VaccinationCenterEntity {
    let api = VaccinationAPI.vaccinationCenter(page: pageIndex, perPage: dataCount, returnType: returnType.rawValue)
    let dto = try await networkManager.request(target: api, type: VaccinationCenterResponseDTO.self)
    return dto.toEntity
  }
}
