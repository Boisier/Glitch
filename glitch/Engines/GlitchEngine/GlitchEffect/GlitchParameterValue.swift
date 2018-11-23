//
//  GlitchParameterValue.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

class GlitchParameterValue {
	let label: String?
	let unit: String?

	var value: Float = 0.0
	let computedValue: String?

	var startValue: Float? {
		return computedValue != nil ? GlitchEngine.instance.decode(computedValue!) : value
	}

	private let _staticMin: Float?
	private let _computedMin: String?

	var min:Float? {
		return _computedMin != nil ? GlitchEngine.instance.decode(_computedMin!) : _staticMin
	}

	let _staticMax: Float?
	let _computedMax: String?

	var max:Float? {
		return _computedMax != nil ? GlitchEngine.instance.decode(_computedMax!) : _staticMax
	}

	let precision:Int
	let step:Float

	init(label: String?,
		 unit: String?,
		 value: Float,
		 computedValue: String?,
		 staticMin: Float?,
		 computedMin: String?,
		 staticMax: Float?,
		 computedMax: String?,
		 precision:Int,
		 step:Float) {

		self.label = label
		self.unit = unit
		self.value = value
		self.computedValue = computedValue

		_staticMin = staticMin
		_computedMin = computedMin

		_staticMax = staticMax
		_computedMax = computedMax

		self.precision = precision
		self.step = step

		self.value = self.startValue ?? 0.0
	}
}
