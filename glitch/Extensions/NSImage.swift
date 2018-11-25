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

	func resize(to tamanho: NSSize) -> NSImage {

		var ratio: Float = 0.0
		let imageWidth = Float(self.size.width)
		let imageHeight = Float(self.size.height)
		let maxWidth = Float(tamanho.width)
		let maxHeight = Float(tamanho.height)

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
