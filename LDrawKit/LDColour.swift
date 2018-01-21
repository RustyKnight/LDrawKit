//
//  LDColour.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 21/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

public protocol ColourID {
  var id: Int { get }
  var description: String { get }
}

public protocol LDColour {
  var legoID: ColourID { get }
  var id: ColourID { get }
  var value: String { get } // #05131D
  var edge: String { get } // #05131D
  
  var alpha: Int { get }
  var luminance:Int { get }
  var material: String { get }
  
  var color: CGColor { get }
  var edgeColor: CGColor { get }
}

public struct DefaultColourID: ColourID {
  public let id: Int
  public let description: String
}

public struct DefaultLDColour: LDColour {
  public let legoID: ColourID
  public let id: ColourID
  public let value: String
  public let edge: String
  public let alpha: Int
  public let luminance: Int
  public let material: String
  
  var alphaValue: CGFloat {
    return min(max(0.0, CGFloat(alpha) / 255.0), 255.0)
  }
  
  public var color: CGColor {
    return CGColor.from(hex: value, alpha: alphaValue)
  }
  public var edgeColor: CGColor {
    return CGColor.from(hex: value, alpha: alphaValue)
  }
  
}

public enum LDColourManagerError: Error {
  case invalidID
  case invalidCommandOrder
  
  case missingCode
  case missingValue
  case missingEdge
}

open class LDColourManager {

  enum Strings: String {
    case legoID = "// LEGOID"
    case color = "!COLOUR"
    case code = "CODE"
    case value = "VALUE"
    case edge = "EDGE"
  }
  
  public var shared: LDColourManager = LDColourManager()
  
  func load(from path: URL) throws {
    let contents = try String(contentsOf: path).components(separatedBy: "\r\n")
    
    var legoID: ColourID? = nil
    for line in contents {
      guard line.starts(with: LineType.comment) else {
        continue
      }
      guard line.starts(with: LineType.comment) else {
        continue
      }
      var text = String(line.dropFirst()).trimming
      if text.starts(with: Strings.legoID) {
        let parts = line.trimming.components(separatedBy: " - ")
        guard let id = Int(parts[0].trimming) else {
          throw LDColourManagerError.invalidID
        }
        let name = parts[1]
        legoID = DefaultColourID(id: id, description: name)
      } else if text.starts(with: Strings.color) {
        guard let legoID = legoID else {
          throw LDColourManagerError.invalidCommandOrder
        }
        text = text.replacingOccurrences(of: Strings.color, with: "").trimming
        text = text.replacingOccurrences(of: "  ", with: "").trimming
        let parts = text.split(separator: " ")
        guard parts[1] == Strings.code else {
          throw LDColourManagerError.missingCode
        }
        guard parts[3] == Strings.value else {
          throw LDColourManagerError.missingValue
        }
        guard parts[5] == Strings.edge else {
          throw LDColourManagerError.missingEdge
        }
        guard let id = Int(String(parts[2]).trimming) else {
          throw LDColourManagerError.invalidID
        }
        
        let colourID = DefaultColourID(id: id,
                                       description: String(parts[0]).trimming)
        
        let colour = DefaultLDColour(legoID: legoID,
                                     id: colourID,
                                     value: String(parts[4]).trimming,
                                     edge: String(parts[6]).trimming,
                                     alpha: 1.0,
                                     luminance: 1.0,
                                     material: "")
      }
    }
  }
}
//func starts<T>(with value: T) -> Bool where T: RawRepresentable, T.RawValue == String {

func ==<T>(lhs: String.SubSequence, rhs: T) -> Bool where T: RawRepresentable, T.RawValue == String {
  return String(lhs) == rhs.rawValue
}
