//
//  FileFinder.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 1/2/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation
import ZIPFoundation
import LogWrapperKit

public protocol FileFinderDelegate {
	
	func find(fileNamed: String) throws -> Data?
	
}

public class FileFinder {
	
	public static let shared: FileFinder = FileFinder()
	public static let searchPaths: [String] = [
		"p/48",
		"p",
		"parts/s",
		"parts",
		"models"
	]
	
	public var delegate: FileFinderDelegate? = nil
	
	var archive: Archive? {
		let bundle = Bundle(for: type(of: self))
		guard let archivePath = bundle.path(forResource: "LDrawParts", ofType: "zip") else {
			log(debug: "Could not find archive in bundle")
			return nil
		}
		let archiveURL = URL(fileURLWithPath: archivePath)
		guard let archive = Archive(url: archiveURL, accessMode: .read) else {
			log(debug: "Could not load archive from \(archivePath)")
			return nil
		}
		return archive
	}
	
	public func find(fileNamed partName: String) throws -> Data?  {
		if let data = try delegate?.find(fileNamed: partName) {
			return data
		}
		
//		let bundle = Bundle(for: type(of: self))
//		guard let archivePath = bundle.path(forResource: "LDrawParts", ofType: "zip") else {
//			log(debug: "Could not find archive in bundle")
//			return nil
//		}
//		let archiveURL = URL(fileURLWithPath: archivePath)
//		guard let archive = Archive(url: archiveURL, accessMode: .read) else {
//			log(debug: "Could not load archive from \(archivePath)")
//			return nil
//		}
		
		guard let archive = archive else {
			log(debug: "Could not load archive")
			return nil
		}
		
		log(debug: "Look for part named \(partName)")
		if let data = find(fileNamed: partName, in: archive) {
			return data
		}
		
		for searchPath in FileFinder.searchPaths {
			let path = searchPath + "/" + partName
			log(debug: "Look for part named \(path)")
			guard let data = find(fileNamed: path, in: archive) else {
				continue
			}
			return data
		}

//		let manager: FileManager = FileManager.default
//		guard !manager.fileExists(atPath: fileNamed) else {
//			return URL(fileURLWithPath: fileNamed)
//		}
//		
//		
//		for searchPath in searchPaths {
//			var prefix = pathPrefix == nil ? URL(fileURLWithPath: searchPath, isDirectory: true) : pathPrefix!.appendingPathComponent(searchPath, isDirectory: true)
//			prefix = prefix.appendingPathComponent(fileNamed)
//			guard manager.fileExists(atPath: fileNamed) else {
//				continue
//			}
//			return prefix
//		}
//		
		return nil
	}
	
	func find(fileNamed partName: String, in archive: Archive) -> Data? {
		guard let entry = archive[partName] else {
			return nil
		}
		let tempName = partName
		let fileManager = FileManager.default
		let tempPath = fileManager.temporaryDirectory
		let tempFile = tempPath.appendingPathComponent(tempName)
		var data: Data?
		do {
			if !fileManager.fileExists(atPath: tempFile.path) {
				log(debug: "Load part named \(tempFile) from archive")
				_ = try archive.extract(entry, to: tempFile)
			}
			data = try Data(contentsOf: tempFile)
		} catch let error {
			log(error: error)
		}
		return data
	}

}
