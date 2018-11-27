//
//  float4x4.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd
import GLKit

/// Adds a convenience initializer
extension float4x4 {
	/// Allow for easier init from a GLKMatrix4
	///
	/// - Parameter matrix: The source matrix
	init(matrix: GLKMatrix4) {
		self.init()
		self = unsafeBitCast(matrix, to: float4x4.self)
	}
}
