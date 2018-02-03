//
//  PartParser.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 1/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

public enum PartError: Error {
	case emptyFile
	case invalidSubFileCommand
	case invalidLineCommand
	case invalidColourID
	case invalidPointValue
	case subFileNotFound
	case invalidTriangleCommand
	case invalidQuadrilateralCommand
	
	case fileNotFound
}


public class PartParsr {
	
	static let SUB_FILE_COMMAND_COUNT = 14
	static let LINE_COMMAND_COUNT = 7
	static let TRIANGLE_COMMAND_COUNT = 10
	static let QUADRILATERAL_COMMAND_COUNT = 13
	
	struct Strings {
		static let comment = "// "
	}

	let path: URL
	let name: String

	var commands: [Command] = []

	var part: DefaultPart!
	
	var defaultBFC: BFC = .counterClockWise
	
	public init(path: URL, name: String) {
		self.path = path
		self.name = name
	}
	
	public func parse() throws -> Part {
		guard let path = FileFinder.shared.find(fileNamed: name, withPathPrefix: path) else {
			throw PartError.fileNotFound
		}
		let contents = try String(contentsOf: path).components(separatedBy: "\r\n").filter { $0.trimming.count > 0 }
		guard contents.count > 0 else {
			throw PartError.emptyFile
		}
		
		part = DefaultPart()
		
		var header: [String] = []
		var index = 0
		while contents[index].trimming.isEmpty || contents[index].starts(with: LineType.comment) {
			guard !contents[index].trimming.isEmpty else {
				index += 1
				continue
			}
			header.append(contents[index])
			index += 1
		}
		
		// The "last" expected line could be a BFC command which needs to be excuted as a
		// command (and not override header values)
		if let last = header.last, last.contains(MetaCommand.bfc) {
			index -= 1
			header.remove(at: index)
		}
		
		parse(header: header)
		
		let commandLines = contents[index...contents.count - 1].map { $0 }
		part.commands = try parse(commands: commandLines)
		
		return part
	}
	
	func parse(header: [String]) {
		guard header.count > 0 else {
			return
		}
		guard LineType.is(comment: header[0]) else {
			return
		}
		if MetaCommand.command(from: header[0]) == nil {
			part.description = header[0]
		}
		
		for line in 1..<header.count {
			var text = header[line]
			text = LineType.comment.text(from: text)
			guard let command = MetaCommand.command(from: text) else {
				continue
			}
			guard MetaCommand.headerItems.contains(command) else {
				log(warning: "\(command) does not appear to be a valid header command")
				continue
			}
			text = command.text(from: text).trimming
			switch command {
			case .name: fallthrough
			case .author: fallthrough
			case .ldrawOrg: fallthrough
			case .help: fallthrough
			case .category: fallthrough
			case .cmdLine: part.meta[command] = text
			case .license: part.license.append(text)
			case .keywords: part.keywords.append(contentsOf: parse(keywords: text))
			case .history: part.history.append(text)
			case .bfc: parse(bfcHeader: text)
			default:
				text = text.replacingOccurrences(of: "//", with: "").trimming
				part.comments.append(text)
				break
			}
		}
	}
	
	func parse(bfcHeader text: String) {
		var fileBFC: BFC = .counterClockWise
		
		if text.contains(BFCCertification.certified) {
			part.bfcCertification = .certified
			// Personally, I wouldn't care, but this is the
			// correct format for the header
			if text.contains(BFC.clockWise) {
				fileBFC = .clockWise
			} else if text.contains(BFC.counterClockWise) {
				fileBFC = .counterClockWise
			}
		} else if text.contains(BFCCertification.notCertified) {
			part.bfcCertification = .notCertified
		}
		
		part.defaultBFC = fileBFC
	}
	
	private func parse(keywords: String) -> [String] {
		return keywords.split(separator: ",").map { $0.trimming }
	}
	
	func parse(commands: [String]) throws -> [Command] {
		for line in commands {
			try parse(command: line)
		}
		return self.commands
	}

	func parse(command line: String) throws {
		//		case comment = "0 "
		//		case subFile = "1 "
		//		case line = "2 "
		//		case triangle = "3 "
		if line.starts(with: LineType.comment) {
			parse(comment: line.removing(upToAndIncluding: LineType.comment).trimming)
		} else if line.starts(with: LineType.subFile) {
			commands.append(try parse(subFile: line.removing(upToAndIncluding: LineType.subFile).trimming))
		} else if line.starts(with: LineType.line) {
			commands.append(try parse(line: line.removing(upToAndIncluding: LineType.line).trimming))
		} else if line.starts(with: LineType.triangle) {
			commands.append(try parse(triangle: line.removing(upToAndIncluding: LineType.triangle).trimming))
		} else if line.starts(with: LineType.quadrilateral) {
			commands.append(try parse(quadrilateral: line.removing(upToAndIncluding: LineType.quadrilateral).trimming))
		} else {
			log(warning: "Ignoring \(line)")
		}
	}
	
	func parse(comment: String) {
		commands.append(DefaultCommentCommand(text: comment.removing(upToAndIncluding: "//").trimming))
	}
	
	private func matrix(from points: [String]) throws -> [Int] {
		var matrix: [Int] = []
		for point in points {
			guard let value = Int(point) else {
				throw PartError.invalidPointValue
			}
			matrix.append(value)
		}
		return matrix
	}
	
	private func point(from values: [String], from: Int, to: Int) throws -> Point3D? {
		let pointValues = values[from...to].map { $0 }
		return try point(from: pointValues)
	}
	
	private func point(from values: [String]) throws -> Point3D? {
		return try DefaultPoint3D(points: values)
	}
	
	func parse(subFile text: String) throws -> SubFileCommand {
		// 16 0 24 0 6 0 0 0 -20 0 0 0 6 box5.dat
		// 0 - color
		// 1 - x
		// 2 - y
		// 3 - z
		// 4-12 - a b c d e f g h i
		// 13 - File
		let parts: [String] = text.trimming.split(separator: " ").map { String($0) }
		guard parts.count == PartParsr.SUB_FILE_COMMAND_COUNT else {
			throw PartError.invalidSubFileCommand
		}
		guard let colourID = Int(parts[0]) else {
			throw PartError.invalidColourID
		}
		guard let colour = LDColourManager.shared.colourBy(id: colourID) else {
			throw PartError.invalidColourID
		}
		
		guard let location = try point(from: parts, from: 1, to: 3) else {
			throw PartError.invalidSubFileCommand
		}
		
		let matrixPoints = parts[4...12].map { $0 }
		let matrix = try self.matrix(from: matrixPoints)
		let subFile = parts[13].replacingOccurrences(of: "\\", with: "/")
		
//		guard let subPath = FileFinder.shared.find(fileNamed: subFile, withPathPrefix: path) else {
//			log(error: "Could not find path for \(path)")
//			throw PartError.subFileNotFound
//		}
//
//		let named = subPath.path
		return try DefaultSubFileCommand(text: text, colour: colour, location: location, matrix: matrix, pathPrefix: path, named: subFile)
	}
	
	func parse(line text: String) throws -> LineCommand {
		// 2 <colour> x1 y1 z1 x2 y2 z2
		//    log(debug: "Line - \(text)")
		let parts = text.components(separatedBy: " ")
		guard parts.count == PartParsr.LINE_COMMAND_COUNT else {
			throw PartError.invalidLineCommand
		}
		
		guard let colourID = Int(parts[0]) else {
			throw PartError.invalidColourID
		}
		//    log(debug: "colourID - \(colourID)")
		guard let colour = LDColourManager.shared.colourBy(id: colourID) else {
			throw PartError.invalidColourID
		}
		
		guard let from = try point(from: parts, from: 1, to: 3) else {
			throw PartError.invalidLineCommand
		}
		guard let to = try point(from: parts, from: 4, to: 6) else {
			throw PartError.invalidLineCommand
		}
		
		let points: [Point3D] = [from, to]
		
		return DefaultLineCommand(text: text, colour: colour, points: points)
	}
	
	func parse(triangle text: String) throws -> TriangleCommand {
		// 3 <colour> x1 y1 z1 x2 y2 z2 x3 y3 z3
		//    log(debug: "Triangle - \(text)")
		
		let parts = text.components(separatedBy: " ")
		guard parts.count == PartParsr.TRIANGLE_COMMAND_COUNT else {
			throw PartError.invalidLineCommand
		}
		
		guard let colourID = Int(parts[0]) else {
			throw PartError.invalidColourID
		}
		//    log(debug: "colourID - \(colourID)")
		guard let colour = LDColourManager.shared.colourBy(id: colourID) else {
			throw PartError.invalidColourID
		}
		
		guard let p1 = try point(from: parts, from: 1, to: 3) else {
			throw PartError.invalidTriangleCommand
		}
		guard let p2 = try point(from: parts, from: 4, to: 6) else {
			throw PartError.invalidTriangleCommand
		}
		guard let p3 = try point(from: parts, from: 7, to: 9) else {
			throw PartError.invalidTriangleCommand
		}
		
		let points: [Point3D] = [p1, p2, p3]
		
		return DefaultTriangleCommand(text: text, colour: colour, points: points)
	}
	
	func parse(quadrilateral text: String) throws -> QuadrilateralCommand {
		// 4 <colour> x1 y1 z1 x2 y2 z2 x3 y3 z3 x4 y4 z4
		//    log(debug: "Quadrilateral - \(text)")
		
		let parts = text.components(separatedBy: " ")
		guard parts.count == PartParsr.QUADRILATERAL_COMMAND_COUNT else {
			throw PartError.invalidLineCommand
		}
		
		guard let colourID = Int(parts[0]) else {
			throw PartError.invalidColourID
		}
		//    log(debug: "colourID - \(colourID)")
		guard let colour = LDColourManager.shared.colourBy(id: colourID) else {
			throw PartError.invalidColourID
		}
		guard let p1 = try point(from: parts, from: 1, to: 3) else {
			throw PartError.invalidQuadrilateralCommand
		}
		guard let p2 = try point(from: parts, from: 4, to: 6) else {
			throw PartError.invalidQuadrilateralCommand
		}
		guard let p3 = try point(from: parts, from: 7, to: 9) else {
			throw PartError.invalidQuadrilateralCommand
		}
		guard let p4 = try point(from: parts, from: 10, to: 12) else {
			throw PartError.invalidQuadrilateralCommand
		}
		
		let points: [Point3D] = [p1, p2, p3, p4]
		
		return DefaultQuadrilateralCommand(text: text, colour: colour, points: points)
	}
}
