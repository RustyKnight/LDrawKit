//
//  Part.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 20/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

/**
LDraw parts are measured in LDraw Units (LDU)
1 brick width/depth = 20 LDU
1 brick height = 24 LDU
1 plate height = 8 LDU
1 stud diameter = 12 LDU
1 stud height = 4 LDU
Real World Approximations
1 LDU = 1/64 in
1 LDU = 0.4 mm
*/

/*
The line type of a line is the first number on the line. The line types are:

0: Comment or META Command
1: Sub-file reference
2: Line
3: Triangle
4: Quadrilateral
5: Optional Line
If the line type of the command is invalid, the line is ignored.
*/

public protocol Part {
	var description: String? { get }
	
	var comments: [String] { get }
	var meta: [MetaCommand: String] { get }
	var keywords: [String]  { get }
	var history: [String]  { get }
	var license: [String]  { get }
	
	var bfcCertification: BFCCertification { get }
	var defaultBFC: BFC { get }
	
	var commands: [Command] { get }
	
	var author: String? { get }
	
	var category: String? { get }
	
	func inverted() -> Part
}

open class DefaultPart: Part {
	
	public var description: String?
	
	public var comments: [String] = []
	public var meta: [MetaCommand: String] = [:]
	public var keywords: [String] = []
	public var history: [String] = []
	public var license: [String] = []
	
	public var bfcCertification: BFCCertification = .notCertified
	public var defaultBFC: BFC = .counterClockWise
	
	public var commands: [Command] = []
	
	public var author: String? {
		return meta[MetaCommand.author]
	}
	
	public var category: String? {
		return meta[MetaCommand.category]
	}
	
	public init() {}
	
	public init(from part: Part) {
		description = part.description
		comments.append(contentsOf: part.comments)
		meta = part.meta
		keywords = part.keywords
		history = part.history
		license = part.license
		bfcCertification = part.bfcCertification
		defaultBFC = part.defaultBFC
	}
//	
//	public func conformingTo(winding: BFC) -> Part {
//		var invertNext = false
//		
//		let needsInverstion = winding != defaultBFC
//		
//		var newCommands: [Command] = []
//		
//		for command in commands {
//			var newCommand: Command? = command
//			if let command = command as? LineCommand {
//				if (needsInverstion && !invertNext) || invertNext {
//					newCommand = command.inverted()
//				}
//				invertNext = false
//			} else if let command = command as? TriangleCommand {
//				if (needsInverstion && !invertNext) || invertNext {
//					newCommand = command.inverted()
//				}
//				invertNext = false
//			} else if let command = command as? QuadrilateralCommand {
//				if (needsInverstion && !invertNext) || invertNext {
//					newCommand = command.inverted()
//				}
//				invertNext = false
//			} else if let command = command as? SubFileCommand {
//				newCommand = command.conformingTo(winding: winding)
//				if invertNext {
//					newCommand = command.inverted()
//				}
//				invertNext = false
//			} else if let command = command as? CommentCommand {
//				guard command.text.starts(with: MetaCommand.bfc) else {
//					newCommand = command
//					continue
//				}
//				let text = command.text.removing(text: MetaCommand.bfc).trimming
//				guard text.starts(with: BFC.invertNext) else {
//					newCommand = command
//					continue
//				}
//				newCommand = nil
//				invertNext = true
//			} else {
//				invertNext = false
//			}
//			if let newCommand = newCommand {
//				newCommands.append(newCommand)
//			}
//		}
//		
//		let conformedPart = DefaultPart(from: self)
//		conformedPart.commands = newCommands
//		
//		return conformedPart
//	}
//	
//	public func inverted() -> Part {
//		var invertNext = false
//		
//		var newCommands: [Command] = []
//		
//		for command in commands {
//			guard !invertNext else {
//				invertNext = false
//				newCommands.append(command)
//				continue
//			}
//			if let command = command as? LineCommand {
//				newCommands.append(command.inverted())
//			} else if let command = command as? TriangleCommand {
//				newCommands.append(command.inverted())
//			} else if let command = command as? QuadrilateralCommand {
//				newCommands.append(command.inverted())
//			} else if let command = command as? SubFileCommand {
//				newCommands.append(command.inverted())
//			} else if let command = command as? CommentCommand {
//				guard command.text.starts(with: MetaCommand.bfc) else {
//					newCommands.append(command)
//					continue
//				}
//				let text = command.text.removing(text: MetaCommand.bfc).trimming
//				guard text.starts(with: BFC.invertNext) else {
//					newCommands.append(command)
//					continue
//				}
//				invertNext = true
//			} else {
//				newCommands.append(command)
//				invertNext = false
//			}
//		}
//		
//		let conformedPart = DefaultPart(from: self)
//		conformedPart.commands = newCommands
//		
//		return conformedPart
//	}
	
}

