//
//  Uniforms.swift
//  glitch
//
//  Created by Valentin Dufois on 08/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

struct Uniforms {
	// Number of effects
	var effectsCount:simd_int1

	// All effects ID in order
	var effectsIdentifiers:simd_int1

	// The number of parameter for each effect in order
	var effectsParametersCount:simd_int1

	// All parameters of all effects is order
	var parametersValues:float4
}

struct ShaderArray {
	var value: float4
}
