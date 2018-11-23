//
//  EffectsList.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

class EffectsList {

	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:EffectsList?

	/// Mark init as private to prevent oustide init
	private init() { }

	/// get an instance of the engine. Instanciate if needed.
	static var instance:EffectsList {
		get {
			guard _instance == nil else { return _instance! }

			_instance = EffectsList()
			return _instance!
		}
	}

	// //////////////////
	// MARK: - Properties

	/// All the currently loaded effects
	internal var _effects:[Int:GlitchEffect] = [Int:GlitchEffect]()

	var effects:[Int:GlitchEffect] { return _effects }

	var effectsKeys:[Int] {
		let keys = Array(_effects.keys)
		return keys.sorted(by: <)
	}

	var lastEffectID:Int = -1
}


// ///////////////////////////////////
// MARK: - Effect adding and removing
extension EffectsList {
	/// Add a new effect to the list, and send a "EffectAdded" notification
	///
	/// - Parameter effectIdentifier: Identifier of the effect to create
	func add(effectIdentifier: Int) {
		let newEffect = GlitchEngine.instance.make(effect: effectIdentifier)
		lastEffectID += 1

		_effects[lastEffectID] = newEffect

		NotificationCenter.default.post(name: Notifications.effectAdded.name, object: nil)
	}

	func remove(effect effectKey: Int) {
		_effects.removeValue(forKey: effectKey)
	}
}


extension EffectsList {
	/// Current effect list uniform
	var uniforms:[Uniforms] {
		// Create empty uniform array
		var uniforms:[Uniforms] = [Uniforms]()

		// pre-calculate the number of effects
		let effectsCount = _effects.count

		// For each effect
		self.effectsKeys.forEach{ effectKey in
			let effect = _effects[effectKey]!

			guard effect.active else { return }

			// Pre-calculate values
			let identifier = effect.identifier
			let parametersCount = effect.parameters.count

			// For each parameter of this effect
			effect.parameters.forEach { parameter in
				// Add a row to the uniforms
				uniforms.append(Uniforms(
					effectsCount: simd_int1(effectsCount),
					effectsIdentifiers: simd_int1(identifier),
					effectsParametersCount: simd_int1(parametersCount),
					parametersValues: parameter.uniformValue
				))
			}
		}

		return uniforms
	}
}
