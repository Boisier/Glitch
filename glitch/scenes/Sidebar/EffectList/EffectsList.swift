//
//  EffectsList.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import simd

/// The EffectsList stores the loaded effect.
///
/// This is where you can add and remove effects.
class EffectsList {

	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:EffectsList?

	/// Mark init as private to prevent oustide init
	private init() { }

	/// Get an instance of the engine. Instanciate if needed.
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

	/// All the effects currently in the list
	var effects:[Int:GlitchEffect] { return _effects }

	/// List off all the keys of the effects currently in the list
	var effectsKeys:[Int] {
		return Array(_effects.keys).sorted(by: <)
	}

	/// ID of the last added effect on the list, used for internal tracking
	private var lastEffectID:Int = -1
}


// ///////////////////////////////////
// MARK: - Effect adding and removing
extension EffectsList {
	/// Add a new effect to the list, and send an "effectAdded" notification
	/// with the ID of the effect attached to it.
	///
	/// - Parameter effectIdentifier: Identifier of the effect to create
	func add(effectIdentifier: Int) -> Int {
		let newEffect = GlitchEngine.instance.make(effect: effectIdentifier)
		lastEffectID += 1

		_effects[lastEffectID] = newEffect

		NotificationCenter.default.post(name: Notifications.effectAdded.name, object: lastEffectID)
		return lastEffectID
	}

	/// Remove an effect on the list by its ID
	///
	/// - Parameter effectKey: ID of the effect to remove
	func remove(effect effectKey: Int) {
		_effects.removeValue(forKey: effectKey)
	}
}
