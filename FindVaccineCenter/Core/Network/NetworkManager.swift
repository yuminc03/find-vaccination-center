//
//  NetworkManager.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/19/24.
//

import Foundation

import Alamofire

enum NetworkReturnType: String {
  case xml = "XML"
  case json = "JSON"
}

protocol NetworkManagerProtocol {
  func request<T: Decodable>(api: TargetType, dto: T.Type) async throws -> T
}

struct NetworkManager: NetworkManagerProtocol {
  
  private init() { }
  
  func request<T: Decodable>(api: TargetType, dto: T.Type) async throws -> T {
    try connectNetwork()
    
    let dataTask = await AF.request(api).serializingDecodable(T.self).result
    switch dataTask {
    case let .success(dto):
      return dto
      
    case let .failure(error):
      if let statusCode = error.responseCode {
        throw VCError.network(.invalidStatusCode(statusCode))
      } else {
        throw VCError.network(.unknown(error))
      }
    }
  }
  
  private func connectNetwork() throws {
    guard NetworkReachabilityManager()?.isReachable == true else {
      throw VCError.network(.notConnected)
    }
  }
}