//
//  Line.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 21/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

/**
 Represents the avaliable types of lines
 */
public enum LineType: String {
  case comment = "0 "
	case subFile = "1 "
	case line = "2 "
	case triangle = "3 "
	case quadrilateral = "4 "
	
	static let items: [LineType] = [
		comment, subFile, line, triangle
	]
	
	static func text(from text: String) -> String {
		guard let command = command(from: text) else {
			return text
		}
		return text.removing(upToAndIncluding: command)
	}

	static func command(from text: String) -> LineType? {
		for item in items {
			guard text.starts(with: item) else {
				continue
			}
			return item
		}
		return nil
	}
	
	static func `is`(comment: String) -> Bool {
		return LineType.command(from: comment) == .comment
	}

	func text(from text: String) -> String {
		return text.removing(upToAndIncluding: self).trimming
	}
}

public enum MetaCommand: String {
	case moved = "~Moved "
	case author = "Author: "
  case bfc = "BFC "
  case category = "!CATEGORY "
  case clear = "CLEAR "
  case cmdLine = "!CMDLINE "
  case colour = "!COLOUR "
  case help = "!HELP "
  case history = "!HISTORY "
  case keywords = "!KEYWORDS "
  case ldrawOrg = "!LDRAW_ORG "
  case license = "!LICENSE "
	case name = "Name: "
  case pause = "PAUSE "
  case print = "PRINT "
  case save = "SAVE "
  case step = "STEP "
  case write = "WRITE "
  
  static let items: [MetaCommand] = [
    moved, author, bfc, category, clear, cmdLine, colour, help, history, keywords,
    ldrawOrg, license, name, pause, print, save, step, write
  ]
	
	static let headerItems: [MetaCommand] = [
		moved, name, author, ldrawOrg, license, help,
		category, keywords, cmdLine, history, bfc
	]
	
	static func command(from text: String) -> MetaCommand? {
		for item in items {
			guard text.starts(with: item) else {
				continue
			}
			return item
		}
		return nil
	}
	
	func text(from text: String) -> String {
		return text.removing(upToAndIncluding: self).trimming
	}
}
//
///**
// Represents a line from a part
// */
//public protocol PartLine {
//  var type: LineType { get }
//  var rawValue: String { get }
//}
//
//public protocol CommentLine: PartLine {
//  var text: String {get}
//}
//
//public protocol MetaCommandLine: CommentLine {
//  var command: MetaCommand {get}
//}
//
//public protocol SubFileCommandLine: PartLine {
//  var subFile: String {get}
//  // Transformation
//}
//
//public protocol LineCommandLine: PartLine {
//  
//}
//
//public protocol TriangleCommandLine: PartLine {
//  
//}
//
//public protocol QuadrilateralCommandLine: PartLine {
//  
//}
//
//public protocol OptionalCommandLine: PartLine {
//  
//}

