//
//  GlitchParameterInteraction.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

/// Defines which interactions to be used to set the parameter
enum GlitchParameterInteraction: String, Codable {
	/// No interaction for the paremter, limits to the fields and steppers
	case `default`

	/// The X (first) value can be set by zooming in or out of the texture
	case magnify

	/// The X (first) value can be set scrolling horizontally on the texture
	case scrollX

	/// The X (first) value can be set scrolling vertically on the texture
	case scrollY

	/// The X (first) and Y (second) value can be set scrolling horizontally and
	/// vertically on the texture
	case scroll2D
}
