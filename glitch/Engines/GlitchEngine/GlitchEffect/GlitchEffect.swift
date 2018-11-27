//
//  GlitchEffect.swift
//  glitch
//
//  Created by Valentin Dufois on 20/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

/// Represent a a glitch effect, with its proprieties and current values.
///
/// - Warning: Do not construct effects yourself, Any needed effect should be declared in JSON
class GlitchEffect {
	// ////////////////////////
	// MARK: Effect properties

	/// Name of the effect
	let name: String

	/// Unique ID of the effect
	let identifier: Int

	/// Number of render pass needed by the effect
	let renderPasses: Int

	/// Parameters of this effect
	var parameters: [GlitchParameter]

	// /////////////////////////////////
	// MARK: Effect instance properties
	
	/// Tell if the effect is activated or not
	var active:Bool = true

	// Tell if the effect is currently selected (for event listening)
	var isSelected:Bool = false

	/// Initializer
	init(name: String,
		 identifier: Int,
		 renderPasses: Int,
		 parameters: [GlitchParameter]) {
		self.name = name
		self.identifier = identifier
		self.renderPasses = renderPasses
		self.parameters = parameters
	}
}

// MARK: - Effect views
extension GlitchEffect {
	/// Get the sidebar view for the effect
	///
	/// - Parameter outlineView: Outline view to which this applies
	/// - Returns: The view
	func getEffectView(for outlineView:NSOutlineView) -> SidebarGlitchItem {
		let view:SidebarGlitchItem = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "glitchEffectCell"), owner: self) as! SidebarGlitchItem

		view.set(effect: self)

		return view
	}


	/// Get the sidebar view for the parameter
	///
	/// - Parameters:
	///   - outlineView: Outline view to which this applies
	///   - index: Index of the parameter
	/// - Returns: The view
	func getParameterView(for outlineView:NSOutlineView, parameter index: Int) -> SidebarGlitchParameter {
		let view:SidebarGlitchParameter = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "glitchEffectParameter"), owner: self) as! SidebarGlitchParameter

		view.set(effect: self, parameter: self.parameters[index])

		return view
	}
}
