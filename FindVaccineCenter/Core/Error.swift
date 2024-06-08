//
//  Error.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/8/24.
//

import Foundation

enum Error {
  case location(LocationError)
  
  enum LocationError {
    /// 위치 권한이 없음
    case unAuthorized
    /// 위치 정보 접근 제한됨
    case restricted
    /// 위치 정보 접근이 거졀됨
    case denied
    case unknown
  }
}
