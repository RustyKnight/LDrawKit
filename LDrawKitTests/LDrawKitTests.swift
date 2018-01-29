//
//  LDrawKitTests.swift
//  LDrawKitTests
//
//  Created by Shane Whitehead on 20/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import XCTest
@testable import LDrawKit

class LDrawKitTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testHeader() {
		do {
			try LDColourManager.shared.load(from: URL(fileURLWithPath: "/Volumes/Big Fat Extension/DevWork/xcode/Lego/LDrawKit/LDConfig.ldr"))
			
			
			let pathPrefix = URL(fileURLWithPath: "/Users/swhitehead/Downloads/ldraw")
			let partPath = "parts/3005.dat"
			print("Read \(partPath) from \(pathPrefix)")
		
			let part = try Part(pathPrefix: pathPrefix, source: partPath)
			
			for command in part.commands {
				print("Command = \(command.type)")
			}
		} catch let error {
			XCTFail("\(error)")
		}
	}
}
