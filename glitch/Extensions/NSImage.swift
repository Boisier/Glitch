//
//  NSImage.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

/// Adds methods to resize and save to a file an NSImage
extension NSImage {
	/// Write the NSImage to the given file path in the given file type
	///
	/// - Parameters:
	///   - file: Destination
	///   - type: FileType
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

	/// resize the image, keeping its aspect ratio, to the given dimensions
	///
	/// - Parameter size: New size of the image
	/// - Returns: A resized version of the image
	func resize(to size: NSSize) -> NSImage {

		var ratio: Float = 0.0
		let imageWidth = Float(self.size.width)
		let imageHeight = Float(self.size.height)
		let maxWidth = Float(size.width)
		let maxHeight = Float(size.height)

		// Get ratio (landscape or portrait)
		if (imageWidth > imageHeight) {
			// Landscape
			ratio = maxWidth / imageWidth;
		}
		else {
			// Portrait
			ratio = maxHeight / imageHeight;
		}

		// Calculate new size based on the ratio
		let newWidth = imageWidth * ratio
		let newHeight = imageHeight * ratio

		let imageSo = CGImageSourceCreateWithData(self.tiffRepresentation! as CFData, nil)
		let options: [NSString: NSObject] = [
			kCGImageSourceThumbnailMaxPixelSize: max(imageWidth, imageHeight) * ratio as NSObject,
			kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject
		]
		let size1 = NSSize(width: Int(newWidth), height: Int(newHeight))
		let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSo!, 0, options as CFDictionary).flatMap {
			NSImage(cgImage: $0, size: size1)
		}

		return scaledImage!
	}
}
