//
//  String+RawRepresentable.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 21/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

extension String {
  func starts<T>(with value: T) -> Bool where T: RawRepresentable, T.RawValue == String {
    return starts(with: value.rawValue)
  }
  
  func replacingOccurrences<T>(of value: T, with text: String) -> String where T: RawRepresentable, T.RawValue == String {
    return replacingOccurrences(of: value.rawValue, with: text)
  }
}
