//
//  String+Mutating.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 22/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

extension String {
	
	func removing<T>(text: T) -> String where T: RawRepresentable, T.RawValue == String {
		return removing(text: text.rawValue)
	}
	
	func removing(text: String) -> String {
		guard let startIndex = index(of: text) else {
			return self
		}
		guard let endIndex = endIndex(of: text) else {
			return self
		}
		
		let prefix = self.prefix(upTo: startIndex)
		let sufix = self.suffix(from: endIndex)
		
		return String(prefix) + String(sufix)
	}
	
	func removing(upToAndIncluding text: String) -> String {
		guard let endIndex = endIndex(of: text) else {
			return self
		}
		
		let sufix = self.suffix(from: endIndex)
		
		return String(sufix)
	}

	func removing<T>(upToAndIncluding text: T) -> String where T: RawRepresentable, T.RawValue == String {
		return removing(upToAndIncluding: text.rawValue)
	}

	func prefix(upTo text: String) -> String? {
		guard let index = index(of: text) else {
			return nil
		}
		return String(prefix(upTo: index))
	}
	
	func index(of string: String, options: CompareOptions = .literal) -> Index? {
		return range(of: string, options: options)?.lowerBound
	}
	
	func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
		return range(of: string, options: options)?.upperBound
	}
	
	func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
		var result: [Index] = []
		var start = startIndex
		while let range = range(of: string, options: options, range: start..<endIndex) {
			result.append(range.lowerBound)
			start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
		}
		return result
	}
	
	func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
		var result: [Range<Index>] = []
		var start = startIndex
		while let range = range(of: string, options: options, range: start..<endIndex) {
			result.append(range)
			start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
		}
		return result
	}
	
}
