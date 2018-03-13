//
//  Command.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 26/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

public protocol Point3D: CustomStringConvertible {
	var x: Double { get }
	var y: Double { get }
	var z: Double { get }
}

public enum Point3DError: Error {
	case invalidPoints
}

open class DefaultPoint3D: Point3D {
	public var x: Double
	public var y: Double
	public var z: Double

	public convenience init?(points: [String]) throws {
		guard points.count == 3 else {
			throw Point3DError.invalidPoints
		}
		guard let xValue = Double(points[0]), let yValue = Double(points[1]), let zValue = Double(points[2]) else {
			throw Point3DError.invalidPoints
		}
		try self.init(points: [xValue, yValue, zValue])
	}
	
	public convenience init?(points: [Double]) throws {
		guard points.count == 3 else {
			throw Point3DError.invalidPoints
		}
		self.init(x: points[0], y: points[1], z: points[2])
	}
	
	public init(x: Double, y: Double, z: Double) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	public var description: String {
		return "DefaultPoint3D: x = \(x); y = \(y); z = \(z)"
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
	
	func baked() -> SubFileCommand
	
//	func conformingTo(winding: BFC) -> SubFileCommand
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

open class DefaultCommand: Command, CustomStringConvertible {
	
	public let type: LineType
	public let text: String

	public init(type: LineType, text: String) {
		self.type = type
		self.text = text
	}
	
  public var description: String {
    return "Command type = \(type); text = \(text)"
  }
	
	public func inverted() -> Command {
		return self
	}
  
}

open class DefaultCommentCommand: DefaultCommand, CommentCommand {
  
  public var bfc: BFC?
  
  public override init(type: LineType = .comment, text: String) {
    super.init(type: type, text: text)
    guard text.starts(with: MetaCommand.bfc) else {
      return
    }
    let comment = text.replacingOccurrences(of: MetaCommand.bfc, with: "").trimming
    bfc = BFC(rawValue: comment)
  }
}

open class DefaultColorCommand: DefaultCommand, ColorCommand {
	
	public let colour: LDColour
	
	public init(type: LineType, text: String, colour: LDColour) {
		self.colour = colour
		super.init(type: type, text: text)
	}
	
	public override var description: String {
		return super.description + "; colour = \(colour)"
	}
	
}

open class DefaultSubFileCommand: DefaultColorCommand, SubFileCommand {

	public var location: Point3D
	public var matrix: [Int]
	public var name: String
	public var commands: [Command] {
		return part.commands
	}
	
	public var part: Part
	
	public init(text: String, colour: LDColour, location: Point3D, matrix: [Int], named: String) throws {
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
	
//	func conformingTo(winding: BFC) -> SubFileCommand {
//		let part = self.part.conformingTo(winding: winding)
//		return DefaultSubFileCommand(text: text, colour: colour, location: location, matrix: matrix, named: name, part: part)
//	}
	
	public func baked() -> SubFileCommand {
		let part = self.part.backed()
		return DefaultSubFileCommand(text: text, colour: colour, location: location, matrix: matrix, named: name, part: part)
	}
	
	public func inverted() -> SubFileCommand {
		let part = self.part.inverted()
		return DefaultSubFileCommand(text: text, colour: colour, location: location, matrix: matrix, named: name, part: part)
	}
	
	public override var description: String {
		return "\(type); \(matrix.map({$0.description}).joined(separator: ", ")); \(location)"
	}

}

open class DefaultMultiPointCommand: DefaultColorCommand, MultiPointCommand {
	
	public var points: [Point3D]

	public init(type: LineType, text: String, colour: LDColour, points: [Point3D]) {
		self.points = points
		super.init(type: type, text: text, colour: colour)
	}
	
	public override var description: String {
		return "\(type); \(points.map({$0.description}).joined(separator: ", "))"
	}

}

open class DefaultLineCommand: DefaultMultiPointCommand, LineCommand {

	public init(text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: .line, text: text, colour: colour, points: points)
	}
	
	public func inverted() -> LineCommand {
		let p = self.points.reversed().map { $0 }
		return DefaultLineCommand(text: self.text, colour: self.colour, points: p)
	}
}

open class DefaultTriangleCommand: DefaultMultiPointCommand, TriangleCommand {
	
	public init(text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: .triangle, text: text, colour: colour, points: points)
	}

	public func inverted() -> TriangleCommand {
		let p = self.points.reversed().map { $0 }
		return DefaultTriangleCommand(text: self.text, colour: self.colour, points: p)
	}

}

open class DefaultQuadrilateralCommand: DefaultMultiPointCommand, QuadrilateralCommand {
	
	public init(text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: .quadrilateral, text: text, colour: colour, points: points)
	}

	public func inverted() -> QuadrilateralCommand {
		let p = self.points.reversed().map { $0 }
		return DefaultQuadrilateralCommand(text: self.text, colour: self.colour, points: p)
	}

}
