//
//  Part.swift
//  LDrawKit
//
//  Created by Shane Whitehead on 20/1/18.
//  Copyright © 2018 Shane Whitehead. All rights reserved.
//

import Foundation

/**
 LDraw parts are measured in LDraw Units (LDU)
 1 brick width/depth = 20 LDU
 1 brick height = 24 LDU
 1 plate height = 8 LDU
 1 stud diameter = 12 LDU
 1 stud height = 4 LDU
 Real World Approximations
 1 LDU = 1/64 in
 1 LDU = 0.4 mm
 */

/*
 The line type of a line is the first number on the line. The line types are:
 
 0: Comment or META Command
 1: Sub-file reference
 2: Line
 3: Triangle
 4: Quadrilateral
 5: Optional Line
 If the line type of the command is invalid, the line is ignored.
 */

public enum PartError: Error {
  case emptyFile
  case missingPartDescription
}

open class Part {
  
  struct Strings {
    static let comment = "// "
  }
  
  let description: String
  
  private(set) var comments: [String] = []
  private(set) var meta: [MetaCommand: String] = [:]
  private(set) var keywords: [String] = []
  private(set) var history: [String] = []
  
  var author: String? {
    return meta[MetaCommand.author]
  }
  
  var bfc: String? {
    return meta[MetaCommand.bfc]
  }
  
  var category: String? {
    return meta[MetaCommand.category]
  }
  
  public init(source: URL) throws {
    let contents = try String(contentsOf: source).components(separatedBy: "\r\n")
    guard contents.count > 0 else {
      throw PartError.emptyFile
    }
        
    guard contents[0].starts(with: LineType.comment) else {
      throw PartError.missingPartDescription
    }
    description = contents[0].replacingOccurrences(of: LineType.comment, with: "")

    var header: [String] = []
    var index = 0
    while contents[index].starts(with: LineType.comment) {
      header.append(contents[index])
      index += 1
    }
    
    parse(header: header)
    
    for line in index..<contents.count {
      parse(line: contents[line])
    }
  }
  
  func parse(header: [String]) {
    
  }
  
  func parse(line: String) {
    if line.starts(with: LineType.comment) {
      parse(comment: line.replacingOccurrences(of: LineType.comment, with: "").trimming)
    }
  }
  
  func parse(comment: String) {
    guard let index = (MetaCommand.items.index { comment.starts(with: $0) }) else {
      // This is probably just a comment :P
      // Or a unoffical meta tag
      comments.append(comment.replacingOccurrences(of: Strings.comment, with: ""))
      return
    }
    let tag = MetaCommand.items[index]
    let content = comment.replacingOccurrences(of: LineType.comment, with: "")
    switch tag {
    case .keywords:
      for keyword in content.split(separator: ",") {
        let trimmed = String(keyword).trimming
        keywords.append(trimmed)
      }
    case .help: break
    case .history: history.append(content)
    default: meta[tag] = content
    }
  }
  
}

//extension String {
//
//  func starts(with line: Part.Meta) -> Bool {
//    return starts(with: line.rawValue)
//  }
//
//  func replacingOccurrences(of line: Part.Meta, with text: String) -> String {
//    return replacingOccurrences(of: line.rawValue, with: text)
//  }
//
//  func starts(with line: Part.LineType) -> Bool {
//    return starts(with: line.rawValue)
//  }
//
//  func replacingOccurrences(of line: Part.LineType, with text: String) -> String {
//    return replacingOccurrences(of: line.rawValue, with: text)
//  }
//}

/*
 Line Type 0
 Line type 0 has two uses. One use is a comment the other is as a META command.
 
 If the first line of a file is a line type 0 the remainder of the line is considered the file title (see Library Header specification). This overrides any META commands on that line.
 
 A comment line is formatted:
 0 // <comment>
 or
 0 <comment>
 
 Where:
 
 <comment> is any string
 
 The form 0 // <comment> is preferred as the // marker clearly indicates that the line is a comment, thereby permitting parsers to stop processing the line.
 
 The form 0 <comment> is deprecated.
 
 META Commands
 A META command is a statement used to tell an LDraw compatible program to do something. There are currently many official META commands and even more unofficial META commands. In a META command, a keyword follows the line type in the line. The keyword must be in all caps. The generic META line format is:
 
 0 !<META command> <additional parameters>
 
 Where:
 
 ! is used to positively identify this as a META command. (Note: A few official meta commands do not start with a ! in order to preserve backwards compatibility, however, all new official META commands must start with a ! and it is strongly recommended that new unofficial meta-commands also start with a !)
 <META command> is any string in all caps
 <additional parameters> is any string. Note that if a META command does not require any additional parameter, none should be given.

 Line Type 1
 Line type 1 is a sub-file reference. The generic format is:
 
 1 <colour> x y z a b c d e f g h i <file>
 
 Where:
 
 <colour> is a number representing the colour of the part. See the Colours section for allowable colour numbers.
 x y z is the x y z coordinate of the part
 a b c d e f g h iis a top left 3x3 matrix of a standard 4x4 homogeneous transformation matrix. This represents the rotation and scaling of the part. The entire 4x4 3D transformation matrix would then take either of the following forms:
 / a d g 0 \   / a b c x \
 | b e h 0 |   | d e f y |
 | c f i 0 |   | g h i z |
 \ x y z 1 /   \ 0 0 0 1 /
 The above two forms are essentially equivalent, but note the location of the transformation portion (x, y, z) relative to the other terms.
 Formally, the transformed point (u', v', w') can be calculated from point (u, v, w) as follows:
 u' = a*u + b*v + c*w + x
 v' = d*u + e*v + f*w + y
 w' = g*u + h*v + i*w + z
 <file> is the filename of the sub-file referenced and must be a valid LDraw filename. Any leading and/or trailing whitespace must be ignored. Normal token separation is otherwise disabled for the filename value.
 Line type 1 should never use the colour 24.
 (The complement colour is neither unique nor symmetric. The complement of the complement of colour X is not necessarily colour X. Using colour 24 for line type 1 will therefore lead to unexpected/undefined results.)
 
 Sub-files can be located in the LDRAW\PARTS sub-directory, the LDRAW\P sub-directory, the LDRAW\MODELS sub-directory, the current file's directory, a path relative to one of these directories, or a full path may be specified. Sub-parts are typically stored in the LDRAW\PARTS\S sub-directory and so are referenced as s\subpart.dat, while hi-res primitives are stored in the LDRAW\P\48 sub-directory and so referenced as 48\hires.dat
 
 While there is no specified limit on how deep sub-files may be nested, there are probably practical limitations imposed by individual software programs.
 
 There are many on-line references about transformation matrices, one such reference is The POV-RAY Matrix Page

 Line Type 2
 Line type 2 is a line drawn between two points. The generic format is:
 
 2 <colour> x1 y1 z1 x2 y2 z2
 
 Where:
 
 <colour> is a number representing the colour of the part, typically this is 24 - the edge colour. See the Colours section for allowable colour numbers.
 x1 y1 z1 is the coordinate of the first point
 x2 y2 z2 is the coordinate of the second point
 Line type 2 (and also 5) is typically used to edge parts. When used in this manner colour 24 must be used for the line. Line type 2 can also be used to represent fine detail in patterns (cf some torso patterns) and when used in this manner any colour may be used for the line. In either case it should be remembered that not all renderers display line types 2 and 5
 
 Line Type 3
 Line type 3 is a filled triangle drawn between three points. The generic format is:
 
 3 <colour> x1 y1 z1 x2 y2 z2 x3 y3 z3
 
 Where:
 
 <colour> is a number representing the colour of the part. See the Colours section for allowable colour numbers.
 x1 y1 z1 is the coordinate of the first point
 x2 y2 z2 is the coordinate of the second point
 x3 y3 z3 is the coordinate of the third point
 See also the comments about polygons at the end of the Line Type 4 section.
 
 Line Type 4
 Line type 4 is a filled quadrilateral (also known as a "quad") drawn between four points. The generic format is:
 
 4 <colour> x1 y1 z1 x2 y2 z2 x3 y3 z3 x4 y4 z4
 
 Where:
 
 <colour> is a number representing the colour of the part. See the Colours section for allowable colour numbers.
 x1 y1 z1 is the coordinate of the first point
 x2 y2 z2 is the coordinate of the second point
 x3 y3 z3 is the coordinate of the third point
 x4 y4 z4 is the coordinate of the fourth point
 
 Line Type 5
 Line type 5 is an optional line. The generic format is:
 
 5 <colour> x1 y1 z1 x2 y2 z2 x3 y3 z3 x4 y4 z4
 
 Where:
 
 <colour> is a number representing the colour of the part, typically this is 24 - the edge colour. See the Colours section for allowable colour numbers.
 x1 y1 z1 is the coordinate of the first point
 x2 y2 z2 is the coordinate of the second point
 x3 y3 z3 is the coordinate of the first control point
 x4 y4 z4 is the coordinate of the second control point
 With an optional line, a line between the first two points will only be drawn if the projections of the last two points (the control points) onto the screen are on the same side of an imaginary line through the projections of the first two points onto the screen.
 
 5 24 Bx By Bz Ex Ey Ez Ax Ay Az Cx Cy Cz
 
 A and C are on the same side of the green line through BE, so BE is drawn.
 
 5 24 Cx Cy Cz Fx Fy Fz Bx By Bz Dx Dy Dz
 
 B and D are not on the same side of the red line through CF, so CF is not drawn.
 
 This serves to "outline" the edges of the curved surface, which is the intent of optional lines.
 As seen above, the control points usually can be choosen from already known points in the object. Since they are never drawn, they can be located anywhere, as long as they have the right controlling properties.
 
 See also the colour comments at the end of the Line Type 2 section.
 */
