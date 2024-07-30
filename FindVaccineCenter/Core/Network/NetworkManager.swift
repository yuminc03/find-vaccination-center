import Foundation

import Alamofire

protocol NetworkManagerProtocol {
  func request<T: Decodable>(target: TargetType, type: T.Type) async throws -> T
}

struct NetworkManager: NetworkManagerProtocol {
  func request<T: Decodable>(target: TargetType, type: T.Type) async throws -> T {
    try checkNetwork()
    
    let data = try await requestData(target: target)
    let result = try JSONDecoder().decode(type, from: data)
    print("Network Response: \(data.toPrittierJSON)")
    return result
  }
  
  private func requestData(target: TargetType) async throws -> Data {
    try checkNetwork()
    
    let dataResponse = await AF.request(target).serializingData().response
    switch dataResponse.result {
    case let .success(data):
      return data
      
    case let .failure(error):
      if let statusCode = error.responseCode {
        print("statusCode: \(statusCode)")
        throw VCError.network(.invalidStatusCode(statusCode))
      } else {
        throw VCError.network(.unknown(error.localizedDescription))
      }
    }
  }
  
  private func checkNetwork() throws {
    guard NetworkReachabilityManager()?.isReachable == true else {
      throw VCError.network(.notConnected)
    }
  }
}
