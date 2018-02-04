//
//  Command.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 26/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

public protocol Point3D {
	var x: Double { get }
	var y: Double { get }
	var z: Double { get }
}

public enum Point3DError: Error {
	case invalidPoints
}

class DefaultPoint3D: Point3D, CustomStringConvertible {
	var x: Double
	var y: Double
	var z: Double

	convenience init?(points: [String]) throws {
		guard points.count == 3 else {
			throw Point3DError.invalidPoints
		}
		guard let xValue = Double(points[0]), let yValue = Double(points[1]), let zValue = Double(points[2]) else {
			throw Point3DError.invalidPoints
		}
		try self.init(points: [xValue, yValue, zValue])
	}
	
	convenience init?(points: [Double]) throws {
		guard points.count == 3 else {
			throw Point3DError.invalidPoints
		}
		self.init(x: points[0], y: points[1], z: points[2])
	}
	
	init(x: Double, y: Double, z: Double) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	var description: String {
		return "DefaultPoint3D: x = \(x); y = \(y); x = \(z)"
	}
}

public protocol Command {
	var text: String { get }// The original text of the command
	var type: LineType { get }
}

public protocol CommentCommand: Command {
  var bfc: BFC? {get}
}

public protocol ColorCommand: Command {
	var colour: LDColour { get }
}

public protocol SubFileCommand: ColorCommand {
	var location: Point3D { get }
	var matrix: [Int] { get } // In the form of a, b, c, d, e, f, g, h, i
	var name: String { get }
	
	var commands: [Command] { get }
	
	func conformingTo(winding: BFC) -> SubFileCommand
	func inverted() -> SubFileCommand
}

public protocol MultiPointCommand: Command {
	var points: [Point3D] { get }
}

public protocol LineCommand: ColorCommand, MultiPointCommand {
	func inverted() -> LineCommand
}

public protocol TriangleCommand: ColorCommand, MultiPointCommand {
	func inverted() -> TriangleCommand
}

public protocol QuadrilateralCommand: ColorCommand, MultiPointCommand {
	func inverted() -> QuadrilateralCommand
}

class DefaultCommand: Command, CustomStringConvertible {
	
	let type: LineType
	let text: String

	init(type: LineType, text: String) {
		self.type = type
		self.text = text
	}
	
  var description: String {
    return "Command type = \(type); text = \(text)"
  }
  
}

class DefaultCommentCommand: DefaultCommand, CommentCommand {
  
  var bfc: BFC?
  
  override init(type: LineType = .comment, text: String) {
    super.init(type: type, text: text)
    guard text.starts(with: MetaCommand.bfc) else {
      return
    }
    let comment = text.replacingOccurrences(of: MetaCommand.bfc, with: "").trimming
    bfc = BFC(rawValue: comment)
  }
}

class DefaultColorCommand: DefaultCommand, ColorCommand {
	
	let colour: LDColour
	
	init(type: LineType, text: String, colour: LDColour) {
		self.colour = colour
		super.init(type: type, text: text)
	}
	
}

class DefaultSubFileCommand: DefaultColorCommand, SubFileCommand {

	var location: Point3D
	var matrix: [Int]
	var name: String
	var commands: [Command] {
		return part.commands
	}
	
	var part: Part
	
	init(text: String, colour: LDColour, location: Point3D, matrix: [Int], named: String) throws {
		self.location = location
		self.matrix = matrix
		self.name = named
		
		self.part = try PartParser(partName: named).parse()
		
//		try self.part = Part(pathPrefix: pathPrefix, source: name)
		super.init(type: .subFile, text: text, colour: colour)
	}
	
	private init(text: String, colour: LDColour, location: Point3D, matrix: [Int], named: String, part: Part) {
		self.location = location
		self.matrix = matrix
		self.name = named
		self.part = part
		super.init(type: .subFile, text: text, colour: colour)
	}
	
	func conformingTo(winding: BFC) -> SubFileCommand {
		let part = self.part.conformingTo(winding: winding)
		return DefaultSubFileCommand(text: text, colour: colour, location: location, matrix: matrix, named: name, part: part)
	}
	
	func inverted() -> SubFileCommand {
		let part = self.part.inverted()
		return DefaultSubFileCommand(text: text, colour: colour, location: location, matrix: matrix, named: name, part: part)
	}

}

class DefaultMultiPointCommand: DefaultColorCommand, MultiPointCommand {
	
	var points: [Point3D]

	init(type: LineType, text: String, colour: LDColour, points: [Point3D]) {
		self.points = points
		super.init(type: type, text: text, colour: colour)
	}

}

class DefaultLineCommand: DefaultMultiPointCommand, LineCommand {

	init(text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: .line, text: text, colour: colour, points: points)
	}
	
	func inverted() -> LineCommand {
		return DefaultLineCommand(text: self.text, colour: self.colour, points: self.points.reversed())
	}
}

class DefaultTriangleCommand: DefaultMultiPointCommand, TriangleCommand {
	
	init(text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: .triangle, text: text, colour: colour, points: points)
	}

	func inverted() -> TriangleCommand {
		return DefaultTriangleCommand(text: self.text, colour: self.colour, points: self.points.reversed())
	}

}

class DefaultQuadrilateralCommand: DefaultMultiPointCommand, QuadrilateralCommand {
	
	init(text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: .quadrilateral, text: text, colour: colour, points: points)
	}

	func inverted() -> QuadrilateralCommand {
		return DefaultQuadrilateralCommand(text: self.text, colour: self.colour, points: self.points.reversed())
	}

}
