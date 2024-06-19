//
//  VCError.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/8/24.
//

import Foundation

/// VaccineCenter 앱에서 사용하는 오류
enum VCError: Error {
  case location(LocationError)
  case network(NetworkError)
  
  /// 위치 관련 오류
  enum LocationError {
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
  enum NetworkError {
    /// URL path encoding 실패
    case percentEncodingFailed
    /// URLString을 URL로 바꾸기 실패
    case creatingURLFailed
    /// Encodable을 Data로 바꾸기 실패
    case encodableToDataFailed
  }
}
