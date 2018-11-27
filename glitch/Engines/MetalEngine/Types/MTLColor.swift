//
//  MTLColor.swift
//  glitch
//
//  Created by Valentin Dufois on 11/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

/// Stores a RGBA color.
/// RGB are on a 0 to 255.0 scale and Alpha on a 0.0 to 1.0 scale
struct MTLColor {
	/// The color components (r = x, g = y, b = z, a = w)
	private var _components:float4

	// MARK: - Initializers

	/// Create a grey color
	///
	/// - Parameter grey: The grey value
	init(grey: Float) {
		self.init(r: grey, g: grey, b: grey, a: 1.0)
	}

	/// Init a grey color and set its opacity
	///
	/// - Parameters:
	///   - grey: The grey value
	///   - alpha: The opacity
	init(grey: Float, alpha: Float) {
		self.init(r: grey, g: grey, b: grey, a: alpha)
	}

	/// Init a RGB color
	///
	/// - Parameters:
	///   - r: Red component
	///   - g: Green component
	///   - b: Blue component
	init(r: Float, g: Float, b: Float) {
		self.init(r: r, g: g, b: b, a: 1.0)
	}


	/// Init a RGB color and set its opacity
	///
	/// - Parameters:
	///   - r: Red component
	///   - g: Green Compoenent
	///   - b: Blue Component
	///   - a: The opacity
	init(r: Float, g: Float, b: Float, a: Float) {
		_components = float4([r, g, b, a])
	}

	// MARK: - Components access

	/// The red component of the color
	var r:Float {
		get { return _components.x }
		set { _components.x = r }
	}

	/// The green component of the color
	var g:Float {
		get { return _components.y }
		set { _components.y = g }
	}

	/// The blue component of the color
	var b:Float {
		get { return _components.z }
		set { _components.z = b }
	}

	/// The opacity of the color
	var a:Float {
		get { return _components.w }
		set { _components.w = a }
	}

	/// The color components
	var rgb:float3 {
		get { return float3([r, g, b]) }
		set { _components = float4([rgb.x, rgb.y, rgb.z, a]) }
	}

	/// All the components
	var rgba:float4 {
		get { return _components }
		set { _components = rgba }
	}


	// MARK: - Specific methods
	/// Return the colors with its R, G and B components normalized.
	var normalized:float4 {
		get { return float4([r/255.0, g/255.0, b/255.0, a]) }
	}


	// MARK: - Predefined colors

	/// White
	static var white:MTLColor { get { return MTLColor(grey: 255.0) } }
	/// Black
	static var black:MTLColor { get { return MTLColor(grey: 0.0) } }
	/// Red
	static var red:MTLColor { get { return MTLColor(r: 255.0, g: 0.0, b: 0.0) } }
	/// Green
	static var green:MTLColor { get { return MTLColor(r: 0.0, g: 255.0, b: 0.0) } }
	/// Blue
	static var blue:MTLColor { get { return MTLColor(r: 0.0, g: 0.0, b: 255.0) } }
	/// Yellow
	static var yellow:MTLColor { get { return MTLColor(r: 255.0, g: 255.0, b: 0.0) } }
	/// Magenta
	static var magenta:MTLColor { get { return MTLColor(r: 255.0, g: 0.0, b: 255.0) } }
	/// Cyan
	static var cyan:MTLColor { get { return MTLColor(r: 0.0, g: 255.0, b: 255.0) } }
}
