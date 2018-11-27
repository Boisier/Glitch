//
//  GlitchParameter.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

/// Represent a parameter of a Glitch Effect
///
/// Internally, a parameter stores its values under the properties x, y, z, w. This
/// is to ensure logic, and prevent uselessly long names such as 'firstValue', or the
/// use of an array. Even though the currently used names tends to refer to positions
/// and directions, a GlitchParameter is a hollow object that treats any values the
/// same way. A GlitchParameter can represent a vector, yes, but also a color, or any
/// arbitrary informations with up to 4 values.
///
/// When converted to a uniform, the parameter stores its values in a float4.
///
/// - Warning: Do not construct parameters yourself, Any needed parameter should be declared in JSON
class GlitchParameter {
	/// Name of the parameter
	let name: String

	/// Type of parameter
	let type: GlitchParameterType
	/// Interactions allowed for this parameter
	let interaction: GlitchParameterInteraction

	/// The parameter first value
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

	/// Puts the parameter value in a float4, respecting the xyzw order. Any missing
	/// values are set to 0.
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
