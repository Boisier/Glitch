//
//  GlitchParameter.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

class GlitchParameter {
	let name: String

	let type: GlitchParameterType
	let interaction: GlitchParameterInteraction

	var x: GlitchParameterValue!
	var y: GlitchParameterValue!
	var z: GlitchParameterValue!
	var w: GlitchParameterValue!

	init(name: String,
		 type: GlitchParameterType,
		 interaction: GlitchParameterInteraction) {
		self.name = name
		self.type = type
		self.interaction = interaction
	}

	/// Generate the appropriate uniform for the parameter
	var uniformValue:float4 {
		switch self.type {
		case .float, .int:
			return float4(x.value, 0, 0, 0)
		case .position2D:
			return float4(x.value, y.value, 0, 0)
		case .position3D:
			return float4(x.value, y.value, z.value, 0)
		}
	}
}
