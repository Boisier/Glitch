//
//  NSImage.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {
	func writeToFile(file: URL, usingType type: NSBitmapImageRep.FileType) {
		let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
		guard
			let imageData = tiffRepresentation,
			let imageRep = NSBitmapImageRep(data: imageData),
			let fileData = imageRep.representation(using: type, properties: properties) else {
				return
		}
		try! fileData.write(to: file, options: [])
	}
}
