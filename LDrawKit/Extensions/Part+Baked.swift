//
//  Part+Flatten.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 4/3/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import LogWrapperKit

public extension Part {
	
	public func backed() -> Part {
		var newCommands: [Command] = []
		
		var invertNext = false
		for var command in commands {
			if let command = command as? CommentCommand {
				let text = command.text.removing(text: MetaCommand.bfc).trimming
				guard text.starts(with: BFC.invertNext) else {
					newCommands.append(command)
					continue
				}
				log(debug: "Invert")
				invertNext = true
			} else if let command = command as? SubFileCommand {
				// Can't completely flatten a sub file, as it has an
				// associated transformation
				if invertNext {
					newCommands.append(command.baked().inverted())
				} else {
					newCommands.append(command.baked())
				}
				invertNext = false
			} else {
				if invertNext {
					newCommands.append(invert(command: command))
				} else {
					newCommands.append(command)
				}
				invertNext = false
			}
		}
		let part = DefaultPart(from: self)
		part.commands = newCommands
		
		return part
	}
	
	func invert(command: Command) -> Command {
		if let command = command as? LineCommand {
			return command.inverted()
		} else if let command = command as? TriangleCommand {
			return command.inverted()
		} else if let command = command as? QuadrilateralCommand {
			return command.inverted()
		} else if let command = command as? SubFileCommand {
			return command.inverted()
		}
		return command
	}
	
}
