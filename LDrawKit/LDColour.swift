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
  var legoID: [ColourID] { get }
  var id: ColourID { get }
  var value: String { get } // #05131D
  var edge: String { get } // #05131D
  
  var alpha: Int { get }
  var luminance:Int? { get }
  var material: String { get }
  
  var color: CGColor { get }
  var edgeColor: CGColor { get }
}

public struct DefaultColourID: ColourID {
  public let id: Int
  public let description: String
}

public struct DefaultLDColour: LDColour, CustomStringConvertible {
  public let legoID: [ColourID]
  public let id: ColourID
  public let value: String
  public let edge: String
  public let alpha: Int
  public let luminance: Int?
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
	
	public var description: String {
		return "LDColour: id = \(id); value = \(value); edge = \(edge); alpha = \(alpha); luminance = \(String(describing: luminance)); material = \(material)"
	}
  
}

public enum LDColourManagerError: Error {
  case invalidID
  case invalidCommandOrder
	case invalidAlpha
	case invalidLine
  
  case missingCode
  case missingValue
  case missingEdge
	
	case invalidKey(key: ColourParameter)
	case noValueForKey(key: ColourParameter)
	
	case catalogNotFound
	case invalidEncoding
}

public enum ColourParameter: String {
	case legoID = "// LEGOID"
	case color = "!COLOUR"
	case code = "CODE"
	case value = "VALUE"
	case edge = "EDGE"
	case alpha = "ALPHA"
	case luminance = "LUMINANCE"
	case comment = "0 "
	
	var range: Range<String.Index> {
		return rawValue.startIndex..<rawValue.index(rawValue.startIndex, offsetBy: rawValue.count)
	}
}

open class LDColourManager {
	
  public static let shared: LDColourManager = LDColourManager()
	
	public private(set) var colours: [LDColour] = []
	
	public func colourBy(id: Int) -> LDColour? {
		return colours.first { $0.id.id == id }
	}
  
  public func load() throws {
		guard let data = try FileFinder.shared.find(fileNamed: "LDConfig.ldr") else {
			throw LDColourManagerError.catalogNotFound
		}
		
		colours = []
		guard let text = String(data: data, encoding: .utf8) else {
			throw LDColourManagerError.invalidEncoding
		}
		
		let contents = text.components(separatedBy: "\r\n")
    
    var legoIDs: [ColourID] = []
    for line in contents {
			var text = line.trimming
      guard text.starts(with: LineType.comment) else {
        continue
      }
			
			text = text.removing(upToAndIncluding: LineType.comment).trimming
      guard text.starts(with: ColourParameter.color) || text.starts(with: ColourParameter.legoID) else {
        continue
      }
      if text.starts(with: ColourParameter.legoID) {
				text = text.removing(upToAndIncluding: ColourParameter.legoID).trimming
				legoIDs = try parse(legoID: text)
      } else if text.starts(with: ColourParameter.color) {
				let colour = try parse(line: text, legoIDs: legoIDs)
				colours.append(colour)
				legoIDs = []
      }
    }
  }
	
	private func parse(legoID value: String) throws -> [ColourID] {
		var ids: [Int] = []
		var descs: [String] = []
		
		// Remove leading identifier
		var text = value.removing(upToAndIncluding: ColourParameter.legoID).trimming
		// Try and get the next element, which should be a colour id
		guard let nextIndex = text.index(of: " ") else {
			throw LDColourManagerError.invalidID
		}
		guard let id = Int(String(text[text.startIndex...nextIndex]).trimming) else {
			throw LDColourManagerError.invalidID
		}
		ids.append(id)
		
		// Remove the leading id
		text = String(text[nextIndex..<text.endIndex]).trimming
		// Is their a separator
		if text.starts(with: "/") {
			// Trim off the leading text up to the next space
			guard var nextIndex = text.index(of: " ") else {
				throw LDColourManagerError.invalidID
			}
			nextIndex = text.index(nextIndex, offsetBy: 1)
			text = String(text[nextIndex..<text.endIndex]).trimming
			// Get the next idea...
			guard let id = Int(String(text[text.startIndex...nextIndex]).trimming) else {
				throw LDColourManagerError.invalidID
			}
			ids.append(id)
			text = String(text[nextIndex..<text.endIndex]).trimming
		}
		if text.starts(with: "-") {
			guard var nextIndex = text.index(of: "-") else {
				throw LDColourManagerError.invalidID
			}
			nextIndex = text.index(nextIndex, offsetBy: 1)
			text = String(text[nextIndex..<text.endIndex]).trimming
		}
		
		if text.contains("/") {
			let parts = text.components(separatedBy: "/")
			descs.append(parts[0].trimming)
			descs.append(parts[1].trimming)
		} else {
			descs.append(text.trimming)
		}
		
		guard ids.count == descs.count else {
			throw LDColourManagerError.invalidID
		}
		
		var colourIDs: [ColourID] = []
		for index in 0..<ids.count {
			colourIDs.append(DefaultColourID(id: ids[index], description: descs[index]))
		}
		
		return colourIDs
	}
	
	private func parse(line value: String, legoIDs: [ColourID]) throws -> LDColour {
		// Remove "0 "
		var text = value.dropFirst().trimming
		// Remove "!COLOR"
		text.replaceSubrange(ColourParameter.color.range, with: "")
		text = text.trimming
		
		// Index of next space...
		guard let index = text.index(of: " ") else {
			throw LDColourManagerError.invalidLine
		}
		// Name...
		let name = String(text[..<index]).trimming
		text = text.removing(text: name).trimming
		
		let code = try next(value: ColourParameter.code, from: text)
		guard let codeID = Int(code) else {
			throw LDColourManagerError.invalidID
		}
		text = text.removing(upToAndIncluding: code).trimming

		let value = try next(value: ColourParameter.value, from: text)
		text = text.removing(upToAndIncluding: value).trimming

		let edge = try next(value: ColourParameter.edge, from: text)
		text = text.removing(upToAndIncluding: edge).trimming

		let alpha = optionalNext(value: ColourParameter.alpha, from: text)
		var alphaValue: Int = 255
		if let alpha = alpha {
			guard let value = Int(alpha) else {
				throw LDColourManagerError.invalidAlpha
			}
			alphaValue = value
			text = text.removing(upToAndIncluding: alpha).trimming
		}
		
		let luminance = optionalNext(value: ColourParameter.luminance, from: text)
		var luminanceValue: Int?
		if let luminance = luminance {
			if let value = Int(luminance) {
				luminanceValue = value
			}
			text = text.removing(upToAndIncluding: luminance).trimming
		}
		
		let material = text.trimming
		
		return DefaultLDColour(legoID: legoIDs,
													 id: DefaultColourID(id: codeID, description: name),
													 value: value,
													 edge: edge,
													 alpha: alphaValue,
													 luminance: luminanceValue,
													 material: material)
	}
	
	private func next(value key: ColourParameter, from text: String) throws -> String {
		guard text.starts(with: key) else {
			throw LDColourManagerError.invalidKey(key: key)
		}
		let remaining = text.removing(text: key).trimming
		guard remaining.contains(" ") else {
			return remaining
		}
		guard let value = remaining.prefix(upTo: " ") else {
			throw LDColourManagerError.noValueForKey(key: key)
		}
		return value.trimming
	}
	
	private func optionalNext(value key: ColourParameter, from text: String) -> String? {
		guard text.starts(with: key) else {
			return nil
		}
		let remaining = text.removing(text: key).trimming
		guard let value = remaining.prefix(upTo: " ") else {
			return nil
		}
		return value.trimming
	}

}
//func starts<T>(with value: T) -> Bool where T: RawRepresentable, T.RawValue == String {

func ==<T>(lhs: String.SubSequence, rhs: T) -> Bool where T: RawRepresentable, T.RawValue == String {
  return String(lhs) == rhs.rawValue
}
func ==<T>(lhs: String, rhs: T) -> Bool where T: RawRepresentable, T.RawValue == String {
	return lhs == rhs.rawValue
}
