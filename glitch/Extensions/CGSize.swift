//
//  CGSize.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

extension CGSize {
	init(width: Float, height: Float) {
		self.init(width: Double(width), height: Double(height))
	}

	var widthFloat:Float { return Float(self.width) }
	var heightFloat:Float { return Float(self.height) }
}
