//
//  Part+Inverted.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 7/3/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

public extension Part {
	
	public func inverted() -> Part {
		let baked = self.backed()
		
		var newCommands: [Command] = []
		
		for command in baked.commands {
			if let command = command as? CommentCommand {
				newCommands.append(command)
//				// Technically, we should not get this, as baked should
//				// have already baked it in
//				let text = command.text.removing(text: MetaCommand.bfc).trimming
//				guard text.starts(with: BFC.invertNext) else {
//					newCommands.append(command)
//					continue
//				}
			} else if let command = command as? SubFileCommand {
				newCommands.append(command)
			} else {
				newCommands.append(invert(command: command))
			}
		}
		let part = DefaultPart(from: self)
		part.commands = newCommands
		
		return part
	}
	
}
