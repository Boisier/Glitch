//
//  SidebarGlitchItem.swift
//  glitch
//
//  Created by Valentin Dufois on 18/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

/// Represent an Effect displayed on the sidebar
///
/// This only represent the line with the effect name and the checkbox. The effect
/// parameter a represented by the much more complete `SidebarGlitchParameter`.
class SidebarGlitchItem: NSTableCellView {
	/// Outlet to the checkbox
	@IBOutlet
	public var status:NSButton!

	/// The glitch effect this view links against
	private var _glitchEffect:GlitchEffect!

	/// Set the effect this view links with
	///
	/// - Parameter effect: The Glitch effect to links with
	func set(effect: GlitchEffect) {
		_glitchEffect = effect

		status.title = _glitchEffect.name
		status?.sizeToFit()
	}

	/// Toggle the state of the view
	///
	/// - Parameter sender: The checkbox
	@IBAction func toggleState(_ sender: NSButton) {
		_glitchEffect.active = !_glitchEffect.active
	}
}
