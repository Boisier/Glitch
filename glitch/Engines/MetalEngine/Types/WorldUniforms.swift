//
//  WorldUniforms.swift
//  glitch
//
//  Created by Valentin Dufois on 09/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

/// The current world uniforms, used to be sent to the GPU
struct WorldUniforms {
	/// The metal layer resolution
	var resolution:float2 = float2(0,0);

	/// The current projection matrix
	var projectionMatrix:float4x4 = float4x4(0.0);
}
