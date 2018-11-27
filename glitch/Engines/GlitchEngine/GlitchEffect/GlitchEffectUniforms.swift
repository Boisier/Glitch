//
//  GlitchEffectUniforms.swift
//  glitch
//
//  Created by Valentin Dufois on 22/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

/// Object used to send the glitch effects value to the compute shader
struct GlitchEffectUniforms {
	/// Current effect
	let currentEffect:simd_int1

	/// Current effect identifier
	let currentEffectIdentifier:simd_int1

	/// Total number of effects
	let effectsCount:simd_int1

	/// Current Pass for this effect
	let currentPass:simd_int1

	/// Number of pass in the effect
	let effectPassCount:simd_int1

	/// All the current effect parameters in order
	let parametersValues:float4
}
