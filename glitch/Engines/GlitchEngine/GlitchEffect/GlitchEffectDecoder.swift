//
//  GlitchEffectDecoder.swift
//  glitch
//
//  Created by Valentin Dufois on 19/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

/// Used to load the available effects from a JSON source
struct GlitchEffectsDecoderEncapsulation: Codable {
	/// List of all the available effect
	let effects: [GlitchEffectDecoder]
}

/// Represent a glitch effect comming from a JSON source
struct GlitchEffectDecoder:Codable {
	/// Name of the effect
	let name: String

	/// Unique ID of the effect
	let identifier: Int

	/// Number of render pass needed by the effect
	let renderPasses: Int

	/// Parameters of this effect
	var parameters : [GlitchParameterDecoder]

	/// Decode the effect into a Glitch Effect, ready to be used
	///
	/// - Returns: The decoded effect
	func decode() -> GlitchEffect {
		return GlitchEffect(
			name: self.name,
			identifier: self.identifier,
			renderPasses: self.renderPasses,
			parameters: self.parameters.map{ $0.decode() }
		)
	}
}

/// Represent a glitch effect parameter comming from a JSON source
struct GlitchParameterDecoder:Codable {
	/// Name of the parameter
	let name: String

	/// Values of this parameter
	var values: [GlitchParameterValueDecoder]

	/// The parameter type
	let type: GlitchParameterType

	/// Possible interactions with this parameter
	let interaction: GlitchParameterInteraction

	/// Decode the parameter into a Glitch Parameter, ready to be used
	///
	/// - Returns: The decoded parameter
	func decode() -> GlitchParameter {

		let parameter = GlitchParameter(
			name: self.name,
			type: self.type,
			interaction: self.interaction
		)

		switch self.type {
		case .position2D:
			parameter.x = self.values[0].decode()
			parameter.y = self.values[1].decode()
		case .position3D:
			parameter.x = self.values[0].decode()
			parameter.y = self.values[1].decode()
			parameter.z = self.values[2].decode()
		case .float, .int:
			parameter.x = self.values[0].decode()
		}

		return parameter
	}
}

/// Represent a glitch effect paramter value comming from a JSON source
struct GlitchParameterValueDecoder:Codable {
	/// Label of the value
	let label: String?
	/// Unit for this value
	let unit: String?

	/// Default value, can be a GLS string
	var value: String = "0.0"

	/// Minimum possible value, can be a GLS string
	let min:String?
	/// Maximum possible value, can be a GLS string
	let max:String?

	// The number of digits after the comma
	let precision:String?

	// Value a an incremental step for this value
	let step:String?

	/// Decode this value into a Glitch Parameter Value ready to be used.
	///
	/// Decoding the effect calculate the GLS string for the current loaded texture
	///
	/// - Returns: The decoded value
	func decode() -> GlitchParameterValue {
		// Parameter value decoding
		var value: Float?, computedValue: String?, staticMin: Float?, computedMin: String?, staticMax:Float?, computedMax: String?

		(value, computedValue) = decodeIfComputed(from: self.value)
		(staticMin, computedMin) = decodeIfComputed(from: self.min)
		(staticMax, computedMax) = decodeIfComputed(from: self.max)

		return GlitchParameterValue(
			label: self.label,
			unit: self.unit,
			value: value ?? 0.0,
			computedValue: computedValue,
			staticMin: staticMin,
			computedMin: computedMin,
			staticMax: staticMax,
			computedMax: computedMax,
			precision: Int(self.precision ?? "2")!,
			step: Float(self.step ?? "1.0")!
		)
	}

	/// Try to decode a given GLS String.
	///
	/// If the given value is not a GLS String, the method tries to convert it to a
	/// Float value.
	///
	/// - Parameter input: The value to try to decode
	/// - Returns: A tuple with the decoded value, and the GLS string if it was one
	func decodeIfComputed(from input:String?) -> (Float?, String?) {
		guard let stringInput:String = input else { return (nil, nil) }

		var staticValue:Float? = nil, computedValue:String? = nil

		if(stringInput.first! == "_") {
			computedValue = stringInput
		} else {
			staticValue = Float(stringInput)
		}

		return (staticValue, computedValue)
	}
}
