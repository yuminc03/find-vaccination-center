import Foundation

@propertyWrapper
struct UD<T: Codable> {
  private let key: UDKey
  
  init(key: UDKey) {
    self.key = key
  }
  
  var wrappedValue: T? {
    get {
      guard let object = UserDefaults.standard.object(forKey: key.rawValue) as? Data,
            let decoded = try? JSONDecoder().decode(T.self, from: object)
      else { return nil }
      return decoded
    }
    set { 
      guard let encoded = try? JSONEncoder().encode(newValue) else { return }
      UserDefaults.standard.setValue(encoded, forKey: key.rawValue)
    }
  }
}

enum UDKey: String {
  case searchList
}

enum UDStorage {
  @UD(key: .searchList) 
  static var searchList: [SearchListItemDTO]?
}
