//
//  GlitchParameterType.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

/// Define the type of effect
///
/// These types determine which interface will used to represent the parameter
enum GlitchParameterType: String, Codable {
	/// A 2D position. Works great with a `GlitchParameterInteraction.scroll2D` interaction
	case position2D

	/// A 3D position
	case position3D

	/// A Single float value. Works great with a `GlitchParameterInteraction.scrollY` interaction
	case float

	/// A Single int value. Works great with a `GlitchParameterInteraction.scrollY` interaction. A value precision of 0 needs to used for this to work.
	case int
}
