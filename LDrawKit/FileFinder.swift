//
//  FileFinder.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 1/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

public struct FileFinder {
	
	public static let shared: FileFinder = FileFinder()

	let searchPaths: [String] = [
		"p/48",
		"p",
		"parts/s",
		"parts",
		"models"
	]
	
	public func find(fileNamed: String, withPathPrefix pathPrefix: URL? = nil) -> URL? {
		let manager: FileManager = FileManager.default
		guard !manager.fileExists(atPath: fileNamed) else {
			return URL(fileURLWithPath: fileNamed)
		}
		
		
		for searchPath in searchPaths {
			var prefix = pathPrefix == nil ? URL(fileURLWithPath: searchPath, isDirectory: true) : pathPrefix!.appendingPathComponent(searchPath, isDirectory: true)
			prefix = prefix.appendingPathComponent(fileNamed)
			guard manager.fileExists(atPath: fileNamed) else {
				continue
			}
			return prefix
		}
		
		return nil
	}

}
