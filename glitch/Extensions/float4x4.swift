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

extension float4x4 {
	init(matrix: GLKMatrix4) {
		self.init()

		self = unsafeBitCast(matrix, to: float4x4.self)
	}
}
