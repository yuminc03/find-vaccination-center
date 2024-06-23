//
//  VCError.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/8/24.
//

import Foundation

/// VaccineCenter 앱에서 사용하는 오류
enum VCError: Error, Equatable {
  case location(LocationError)
  case network(NetworkError)
  
  /// 위치 관련 오류
  enum LocationError: Equatable {
    /// 위치 권한이 없음
    case unAuthorized
    /// 위치 정보 접근 제한됨
    case restricted
    /// 위치 정보 접근이 거졀됨
    case denied
    /// 알 수 없는 오류
    case unknown
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
    case invalidStatusCode(Int)
    /// 알 수 없는 오류
    case unknown(Error? = nil)
    
    static func == (lhs: VCError.NetworkError, rhs: VCError.NetworkError) -> Bool {
      switch lhs {
      case .percentEncodingFailed:
        return rhs == .percentEncodingFailed
        
      case .creatingURLFailed:
        return rhs == .creatingURLFailed
        
      case .encodableToDataFailed:
        return rhs == .encodableToDataFailed
        
      case .notConnected:
        return rhs == .notConnected
        
      case let .invalidStatusCode(code):
        switch rhs {
        case let .invalidStatusCode(code2):
          if code == code2 {
            return true
          } else {
            return false
          }
          
        default: return false
        }
        
      case let .unknown(error):
        switch rhs {
        case let .unknown(error2):
          if error?.localizedDescription == error2?.localizedDescription {
            return true
          } else {
            return false
          }
          
        default: return false
        }
      }
    }
  }
}

extension Error {
  var toVCError: VCError {
    return self as? VCError ?? .network(.unknown())
  }
}
