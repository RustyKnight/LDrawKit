//
//  TestCommand.swift
//  LDrawKitTests
//
//  Created by Shane Whitehead on 7/3/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import XCTest
@testable import LDrawKit

class TestCommand: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testCanInvertLine() {
//		public struct DefaultColourID: ColourID {
//			public let id: Int
//			public let description: String
//		public struct DefaultLDColour: LDColour, CustomStringConvertible {
//			public let legoID: [ColourID]
//			public let id: ColourID
//			public let value: String
//			public let edge: String
//			public let alpha: Int
//			public let luminance: Int?
//			public let material: String
		
		let id = DefaultColourID(id: 1, description: "")
		let color = DefaultLDColour(legoID: [], id: id, value: "123", edge: "123", alpha: 255, luminance: nil, material: "none")
		
		let command: DefaultLineCommand = DefaultLineCommand(text: "1 2 3 4 5", colour: color, points: [DefaultPoint3D(x: 1, y: 2, z: 3), DefaultPoint3D(x: 3, y: 4, z: 5)])
		let invert: LineCommand = command.inverted()
		print(command)
		print(invert)
	}
	
}
