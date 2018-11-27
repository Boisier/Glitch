//
//  GlitchParameterValue.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

/// Represent a value of a GlitchParameter
///
/// A value takes the form a Float value, with multiple properties allowing for
/// specific usage. The optional label and unit properties are here to guide the user
/// when specifying this value. The computed* fields are here to holds GLS string used
/// for specifying properties relying on the current texture properties. The computed values will
/// always be prefered when getting the corresponding parameter. The computedValue GLS string is
/// only used when the effect is generated or on texture change.
///
/// - Warning: Do not construct values yourself, Any needed value should be declared in JSON
class GlitchParameterValue {
	/// Label describing the value
	let label: String?
	/// Unit for this value
	let unit: String?

	/// The current valye
	var value: Float = 0.0
	/// The computed value, used on texture change or when the effect is added
	let computedValue: String?

	/// Tells what value should be used when effect is added or when the texture is updated
	var startValue: Float? {
		return computedValue != nil ? GlitchEngine.instance.decode(computedValue!) : value
	}

	/// The static minimum value
	private let _staticMin: Float?
	/// The GLS minimum value
	private let _computedMin: String?

	/// Gets the static min or computed min if present
	var min:Float? {
		return _computedMin != nil ? GlitchEngine.instance.decode(_computedMin!) : _staticMin
	}

	/// The static maximum value
	let _staticMax: Float?
	/// The GLS maximum value
	let _computedMax: String?

	/// Gets the static max or computed max if present
	var max:Float? {
		return _computedMax != nil ? GlitchEngine.instance.decode(_computedMax!) : _staticMax
	}

	/// The precision to use for this value
	let precision:Int
	/// The value incremental step
	let step:Float

	/// - Warning: Do not use this constructor. Any effect should be declared in JSON
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
