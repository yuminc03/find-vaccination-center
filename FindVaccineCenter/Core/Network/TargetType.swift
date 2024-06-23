import Foundation

import Alamofire

protocol TargetType: URLRequestConvertible {
  var baseURL: String { get }
  var path: String { get }
  var httpMethod: HTTPMethod { get }
  var headers: [String: String]? { get }
  var task: Task { get }
}

extension TargetType {
  func asURLRequest() throws -> URLRequest {
    guard let encodedPath = path.addingPercentEncoding(
      withAllowedCharacters: .urlQueryAllowed
    ) else {
      throw VCError.network(.percentEncodingFailed)
    }
    
    guard let url = URL(
      string: "\(baseURL)\(encodedPath)&serviceKey=\(Constants.apiServiceKey.toEncoding)"
    ) else {
      throw VCError.network(.creatingURLFailed)
    }
    
    print("URL: \(url)")
    var urlRequest = URLRequest(url: url, timeoutInterval: 10.0)
    urlRequest.method = httpMethod
    urlRequest.allHTTPHeaderFields = headers
    
    switch task {
    case .plain:
      break
      
    case let .body(encodable):
      let data = try JSONEncoder().encode(encodable)
      urlRequest.httpBody = data
      
    case .upload:
      break
    }
    
    return urlRequest
  }
}

enum Task {
  case plain
  case body(Encodable)
  case upload
}
