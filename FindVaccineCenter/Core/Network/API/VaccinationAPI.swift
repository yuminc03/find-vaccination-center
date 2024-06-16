//
//  VaccinationAPI.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/16/24.
//

import Foundation

import Alamofire

/// 코로나19 예방접종센터 조회서비스
enum VaccinationAPI: TargetType {
  /// 예방접종센터 위치정보 API(GET)
  case vaccinationCenter
}

extension VaccinationAPI {
  var baseURL: String {
    return "api.odcloud.kr/api"
  }
  
  var path: String {
    switch self {
    case .vaccinationCenter:
      return "/15077586/v1/centers"
    }
  }
  
  var httpMethod: HTTPMethod {
    switch self {
    case .vaccinationCenter:
      return .get
    }
  }
  
  var headers: [String: String]? {
    return [:]
  }
  
  var task: Task {
    switch self {
    case .vaccinationCenter:
      return .plain
    }
  }
}
