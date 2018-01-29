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

public protocol ColorCommand: Command {
	var colour: LDColour { get }
}

public protocol SubFileCommand: ColorCommand {
	var location: Point3D { get }
	var matrix: [Int] { get } // In the form of a, b, c, d, e, f, g, h, i
	var path: String { get }
	
	var commands: [Command] { get }
}

public protocol MultiPointCommand: Command {
	var points: [Point3D] { get }
}

public protocol LineCommand: ColorCommand, MultiPointCommand {
}

public protocol TriangleCommand: ColorCommand, MultiPointCommand {
}

public protocol QuadrilateralCommand: ColorCommand, MultiPointCommand {
}

class DefaultCommand: Command {
	
	let type: LineType
	let text: String

	init(type: LineType, text: String) {
		self.type = type
		self.text = text
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
	var path: String
	var commands: [Command] {
		return part.commands
	}
	
	var part: Part
	
	init(type: LineType = .subFile, text: String, colour: LDColour, location: Point3D, matrix: [Int], pathPrefix: URL, path: String) throws {
		self.location = location
		self.matrix = matrix
		self.path = path
		try self.part = Part(pathPrefix: pathPrefix, source: path)
		super.init(type: type, text: text, colour: colour)
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

	override init(type: LineType = .line, text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: type, text: text, colour: colour, points: points)
	}
	
}

class DefaultTriangleCommand: DefaultMultiPointCommand, TriangleCommand {
	
	override init(type: LineType = .line, text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: type, text: text, colour: colour, points: points)
	}
	
}

class DefaultQuadrilateralCommand: DefaultMultiPointCommand, QuadrilateralCommand {
	
	override init(type: LineType = .line, text: String, colour: LDColour, points: [Point3D]) {
		super.init(type: type, text: text, colour: colour, points: points)
	}
	
}
