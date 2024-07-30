import Foundation

import Alamofire

/// 코로나19 예방접종센터 조회서비스
enum VaccinationAPI: TargetType {
  /// 예방접종센터 위치정보 API(GET)
  case vaccinationCenter(page: Int, perPage: Int, returnType: String)
}

extension VaccinationAPI {
  var baseURL: String {
    return "https://api.odcloud.kr/api"
  }
  
  var path: String {
    switch self {
    case let .vaccinationCenter(pageIndex, perPage, returnType):
      return "/15077586/v1/centers?page=\(pageIndex)&perPage=\(perPage)&returnType=\(returnType)"
    }
  }
  
  var httpMethod: HTTPMethod {
    switch self {
    case .vaccinationCenter:
      return .get
    }
  }
  
  var headers: [String: String]? {
    return .authorization
  }
  
  var task: HTTPTask {
    switch self {
    case .vaccinationCenter:
      return .plain
    }
  }
}
