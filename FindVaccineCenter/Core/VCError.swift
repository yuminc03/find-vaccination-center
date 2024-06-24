//
//  VCError.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/8/24.
//

import Foundation

/// VaccineCenter 앱에서 사용하는 오류
enum VCError: LocalizedError, Equatable {
  case location(LocationError)
  case network(NetworkError)
  case unknown(String)
  
  var errorDescription: String? {
    switch self {
    case let .location(error):
      return error.message
    case let .network(error):
      return error.message
    case .unknown:
      return "알 수 없는 오류"
    }
  }
  
  static func == (lhs: VCError, rhs: VCError) -> Bool {
    return lhs.errorDescription == rhs.errorDescription
  }
}

extension VCError {
  /// 위치 관련 오류
  enum LocationError: Equatable {
    /// 위치 권한이 없음
    case unAuthorized
    /// 위치 정보 접근 제한됨
    case restricted
    /// 위치 정보 접근이 거절됨
    case denied
    /// 알 수 없는 오류
    case unknown(String? = nil)
    
    var message: String {
      switch self {
      case .unAuthorized:
        return "위치 권한이 없음"
      case .restricted:
        return "위치 정보 접근 제한됨"
      case .denied:
        return "위치 정보 접근이 거절됨"
      case .unknown:
        return "알 수 없는 오류"
      }
    }
  }
  
  /// 네트워크 통신 오류
  enum NetworkError: Equatable {
    /// URL path encoding 실패
    case percentEncodingFailed
    /// URLString을 URL로 바꾸기 실패
    case creatingURLFailed
    /// Encodable을 Data로 바꾸기 실패
    case encodableToDataFailed
    /// 네트워크 연결이 안되어 있음
    case notConnected
    /// 유효하지 않은 상태 코드
    case invalidStatusCode(Int? = nil)
    /// 알 수 없는 오류
    case unknown(String? = nil)
    
    var message: String {
      switch self {
      case .percentEncodingFailed:
        return "URL path encoding 실패"
      case .creatingURLFailed:
        return "URLString을 URL로 바꾸기 실패"
      case .encodableToDataFailed:
        return "Encodable을 Data로 바꾸기 실패"
      case .notConnected:
        return "네트워크 연결이 안되어 있음"
      case .invalidStatusCode:
        return "유효하지 않은 상태 코드"
      case .unknown:
        return "알 수 없는 오류"
      }
    }
  }
}

extension Error {
  var toVCError: VCError {
    return self as? VCError ?? .unknown(localizedDescription)
  }
}
