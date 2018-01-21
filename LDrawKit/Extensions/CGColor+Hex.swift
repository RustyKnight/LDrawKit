//
//  CGColor+Hex.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 21/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

extension CGColor {
  static func from(hex: String, alpha: CGFloat = 1.0) -> CGColor {
    let scanner = Scanner(string: hex)
    scanner.scanLocation = 0
    
    var rgbValue: UInt64 = 0
    
    scanner.scanHexInt64(&rgbValue)
    
    let r = (rgbValue & 0xff0000) >> 16
    let g = (rgbValue & 0xff00) >> 8
    let b = rgbValue & 0xff
    
    return CGColor(
      red: CGFloat(r) / 0xff,
      green: CGFloat(g) / 0xff,
      blue: CGFloat(b) / 0xff, alpha: alpha
    )
  }
}
