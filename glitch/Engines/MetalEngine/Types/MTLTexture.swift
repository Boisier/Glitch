//
//  MTLTexture.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import Metal

/// Adds methods for conversion
extension MTLTexture {
	/// Returns the current region of the texture
	var region:MTLRegion {
		return MTLRegionMake2D(0, 0, self.width, self.height)
	}

	/// return an `UnsafeMutableRawPointer` to the texture's data
	///
	/// - Returns: Pointer to the texture's data
	func bytes() -> UnsafeMutableRawPointer {
		let width = self.width
		let height   = self.height
		let rowBytes = self.width * 4
		let p = malloc(width * height * 4)

		self.getBytes(p!, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)

		return p!
	}

	/// Convert the texture to a CGImage
	///
	/// - Returns: A CGImage representing the texture
	func toImage() -> CGImage? {
		let p = bytes()

		let pColorSpace = CGColorSpaceCreateDeviceRGB()

		let rawBitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
		let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: rawBitmapInfo)

		let selftureSize = self.width * self.height * 4
		let rowBytes = self.width * 4
		let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
			return
		}
		let provider = CGDataProvider(dataInfo: nil, data: p, size: selftureSize, releaseData: releaseMaskImagePixelData)
		let cgImageRef = CGImage(width: self.width, height: self.height, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: rowBytes, space: pColorSpace, bitmapInfo: bitmapInfo, provider: provider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)!

		return cgImageRef
	}
}
