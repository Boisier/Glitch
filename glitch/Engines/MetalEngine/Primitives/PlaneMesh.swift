//
//  PlaneMesh.swift
//  glitch
//
//  Created by Valentin Dufois on 10/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd
import GLKit

/// A plane mesh is a convenient representation of a 2D plane facing the camera.
///
/// This class simplifies the creation of a simple plane when doing 2D rendering
class PlaneMesh: Mesh {

	var size:CGSize
	var position:float3

	init(x: Float, y: Float, width: Float, height: Float) {
		let vertexData:[Vertex] = [
			Vertex(float3(-Mesh.DEMI_UNIT,  Mesh.DEMI_UNIT, 0.0), float2( 0.0, 1.0 )),
			Vertex(float3(-Mesh.DEMI_UNIT, -Mesh.DEMI_UNIT, 0.0), float2( 0.0, 0.0 )),
			Vertex(float3( Mesh.DEMI_UNIT,  Mesh.DEMI_UNIT, 0.0), float2( 1.0, 1.0 )),
			Vertex(float3( Mesh.DEMI_UNIT, -Mesh.DEMI_UNIT, 0.0), float2( 1.0, 0.0 )),
		]

		self.size = CGSize(width: width, height: height)
		self.position = float3(x, y, 0.0)

		// Init the mesh
		super.init(vertices: vertexData)

		// set up the type of primitives
		self.primitiveType = .triangleStrip
	}

	override var _mergedTransformations: float4x4 { get {
			let positionMatrix = super.positionDeltaFromAnchor * float4x4(matrix: GLKMatrix4MakeTranslation(position.x, position.y, position.z))
			let meshTransformations = super._transformations.reduce(into: positionMatrix) { $0 *= $1 }
			return meshTransformations * float4x4(matrix: GLKMatrix4MakeScale(size.widthFloat, size.heightFloat, 0.0))
		}
		set { }
	}

		// Position and scaling
		// self.translate(x: x, y: y, z: 0)
		// self.scale(x: width, y: height, z: 1.0)

}
