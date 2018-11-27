//
//  Vertex.swift
//  glitch
//
//  Created by Valentin Dufois on 08/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

/// Represent a simple 2D Vertex with a 3D position and 2D UV
struct Vertex {
	/// The vertex position
	var position:float3

	/// The vertex UV coordinates
	var uv:float2

	/// Vertex initialize
	///
	/// - Parameters:
	///   - pos: Vertex position
	///   - uv: Vertex UV coordinates
	init(_ pos:vector_float3, _ uv:vector_float2) {
		self.position = pos
		self.uv = uv
	}
}
