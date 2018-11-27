//
//  CGSize.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

/// Adds convenient method to use CGSize with Float values
extension CGSize {
	/// Convenience init to create a CGsIze with Float values
	///
	/// - Parameters:
	///   - width: <#width description#>
	///   - height: <#height description#>
	init(width: Float, height: Float) {
		self.init(width: Double(width), height: Double(height))
	}

	/// Gets the width as Float
	var widthFloat:Float { return Float(self.width) }

	/// Gets the height as Float
	var heightFloat:Float { return Float(self.height) }
}
