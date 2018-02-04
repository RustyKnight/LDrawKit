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
			try LDColourManager.shared.load()
			
			
//			let pathPrefix = URL(fileURLWithPath: "/Users/swhitehead/Downloads/ldraw")
			let named = "parts/3005.dat"
			print("Read \(named)")
			
			let part = try PartParser(partName: named).parse()
		
//			let part = try Part(pathPrefix: pathPrefix, source: partPath)
			dump(part.commands)
			
			print("-----")
			let baked = part.conformingTo(winding: .counterClockWise)
			dump(baked.commands)
		} catch let error {
			XCTFail("\(error)")
		}
	}
	
	func dump(_ commands: [Command]) {
		for command in commands {
			print(command)
			if let subFileCommand = command as? SubFileCommand {
				dump(subFileCommand.commands)
			}
		}
	}
}
