//
//  Line.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 21/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

/**
 Represents the avaliable types of lines
 */
public enum LineType: String {
  case comment = "0 "
}

public enum MetaCommand: String {
  case author = "Author"
  case bfc = "BFC"
  case category = "!CATEGORY"
  case clear = "CLEAR"
  case cmdLine = "!CMDLINE"
  case colour = "!COLOUR"
  case help = "!HELP"
  case history = "!HISTORY"
  case keywords = "!KEYWORDS"
  case ldrawOrg = "!LDRAW_ORG"
  case license = "!LICENSE"
  case name = "Name"
  case pause = "PAUSE"
  case print = "PRINT"
  case save = "SAVE"
  case step = "STEP"
  case write = "WRITE"
  
  static let items: [Meta] = [
    author, bfc, category, clear, cmdLine, colour, help, history, keywords,
    ldrawOrg, license, name, pause, print, save, step, write
  ]
}

public enum BFC: String {
  case certified = "CERTIFY"
  case notCertified = "NOCERTIFY"
  case clockWise = "CW"
  case counterClockWise = "CCW"
  case cull = "CLIP"
  case noCull = "NOCLIP"
  case invertNext = "INVERTNEXT"
}

/**
 Represents a line from a part
 */
public protocol PartLine {
  var type: LineType { get }
  var rawValue: String { get }
}

public protocol CommentLine: PartLine {
  var text: String {get}
}

public protocol MetaCommandLine: CommentLine {
  var command: MetaCommand {get}
}

public protocol SubFileCommandLine: PartLine {
  var subFile: String {get}
  // Transformation
}

public protocol LineCommandLine: PartLine {
  
}

public protocol TriangleCommandLine: PartLine {
  
}

public protocol QuadrilateralCommandLine: PartLine {
  
}

public protocol OptionalCommandLine: PartLine {
  
}
