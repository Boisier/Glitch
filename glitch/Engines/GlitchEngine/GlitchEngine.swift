//
//  GlitchEngine.swift
//  glitch
//
//  Created by Valentin Dufois on 20/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

class GlitchEngine {

	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:GlitchEngine?

	/// Mark init as private to prevent oustide init
	private init() {
		loadEffects()
	}

	/// get an instance of the engine. Instanciate if needed.
	static var instance:GlitchEngine {
		get {
			guard _instance == nil else { return _instance! }

			_instance = GlitchEngine()
			return _instance!
		}
	}


	// /////////////////////////////////
	// MARK: Glitch stored informations

	private var _availableEffects:[GlitchEffectDecoder]!

	var availableEffects:[GlitchEffectDecoder] {
		get { return _availableEffects! }
	}
}


// MARK: - Effects loading
extension GlitchEngine {
	/// Load all available effects from the source JSON file
	private func loadEffects() -> Void {
		// Load the JSON file in a decoder
		let availableEffectsFilePath = Bundle.main.url(forResource: "availableEffects", withExtension: "json")!
		let availableEffectsJSON = try! Data(contentsOf: availableEffectsFilePath)

		let decoder = JSONDecoder()
		let availableEffectsToDecode:GlitchEffectsDecoderEncapsulation = try! decoder.decode(GlitchEffectsDecoderEncapsulation.self, from: availableEffectsJSON)

		_availableEffects = availableEffectsToDecode.effects
	}
}


// MARK: - Effects Lifecycle
extension GlitchEngine {
	/// Create a new effect, add it to the list, and return its index
	///
	/// - Parameter effect: ID of the current effect
	/// - Returns: The newly created effect index
	func make(effect: Int) -> GlitchEffect {
		return _availableEffects!.filter{ $0.identifier == effect }.first!.decode()
	}
}

// MARK: - Glitch Positionning Language (GLS) decoder
extension GlitchEngine {
	/// Decode a GLS string
	///
	/// All GLS String starts with an underscore (_)
	/// Standard format is _<Value>[:Modifier]
	/// Available values :
	///   * w -> Texture width
	///   * h -> Texture height
	///
	/// Available Modifiers :
	///   * center -> Divides the value by two
	///   * More to come
	///
	/// - Parameter gldString: The string to decode
	/// - Returns: The decoded value. Will return 0.0 in case of failure
	func decode(_ gldString: String) -> Float {
		guard gldString.first == "_" else { return 0.0 }

		var components = gldString.split(separator: "_")[0].split(separator: ":")

		var value:Float = 0.0

		// Set the used value
		switch components[0] {
		case "w": value = MetalEngine.instance.frame.size.widthFloat
		case "h": value = MetalEngine.instance.frame.size.heightFloat
		default: return 0.0 // Bad value
		}

		// Applies the modifiers
		components.removeFirst()
		components.forEach { modifier in
			switch modifier {
			case "center": value /= 2.0
			default: return
			}
		}

		return value
	}
}
