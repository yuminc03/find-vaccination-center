//
//  String+.swift
//  FindVaccineCenter
//
//  Created by Yumin Chu on 6/23/24.
//

import Foundation

extension String {
  /// URL encoding할 때 제외된 다른 특수문자들까지 encoding할 때 사용함
  var toEncoding: String {
    var urlQueryAllowedSet = NSCharacterSet.urlQueryAllowed
    urlQueryAllowedSet.remove(charactersIn: ";/?:@&=+$, ")
    guard let encodedStr = addingPercentEncoding(
      withAllowedCharacters: urlQueryAllowedSet
    ) else {
      print("string encoding 실패.")
      return self
    }
    
    return encodedStr
  }
}
