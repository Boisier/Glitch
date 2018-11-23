//
//  GlitchEffectDecoder.swift
//  glitch
//
//  Created by Valentin Dufois on 19/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

struct GlitchEffectsDecoderEncapsulation: Codable {
	let effects: [GlitchEffectDecoder]
}

struct GlitchEffectDecoder:Codable {
	let name: String
	let identifier: Int
	var parameters : [GlitchParameterDecoder]

	func decode() -> GlitchEffect {
		return GlitchEffect(
			name: self.name,
			identifier: self.identifier,
			parameters: self.parameters.map{ $0.decode() }
		)
	}
}

struct GlitchParameterDecoder:Codable {
	let name: String
	var values: [GlitchParameterValueDecoder]

	let type: GlitchParameterType
	let interaction: GlitchParameterInteraction

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

struct GlitchParameterValueDecoder:Codable {
	let label: String?
	let unit: String?

	var value: String = "0.0"

	let min:String?
	let max:String?
	let precision:String?
	let step:String?

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
