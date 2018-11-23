//
//  Vertex.swift
//  glitch
//
//  Created by Valentin Dufois on 08/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

struct Vertex {
	var position:float3
	var uv:float2

	init(_ pos:vector_float3, _ uv:vector_float2) {
		self.position = pos
		self.uv = uv
	}
}
