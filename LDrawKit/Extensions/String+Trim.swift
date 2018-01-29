//
//  String+Trim.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 21/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

extension String {
  var trimming: String {
    return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }
  
  var trimmingWhiteSpaces: String {
    return trimmingCharacters(in: CharacterSet.whitespaces)
  }
  
  var trimmingNewLines: String {
    return trimmingCharacters(in: CharacterSet.newlines)
  }
}

extension String.SubSequence {
	var trimming: String {
		return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	var trimmingWhiteSpaces: String {
		return trimmingCharacters(in: CharacterSet.whitespaces)
	}
	
	var trimmingNewLines: String {
		return trimmingCharacters(in: CharacterSet.newlines)
	}
}
