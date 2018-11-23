//
//  GlitchEffect.swift
//  glitch
//
//  Created by Valentin Dufois on 20/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

class GlitchEffect {
	// ////////////////////////
	// MARK: Effect properties

	let name: String
	let identifier: Int
	var parameters: [GlitchParameter]

	// /////////////////////////////////
	// MARK: Effect instance properties
	var active:Bool = true

	// Tell if the effect is currently selected (for event listening)
	var isSelected:Bool = false

	/// Initializer
	init(name: String,
		 identifier: Int,
		 parameters: [GlitchParameter]) {
		self.name = name
		self.identifier = identifier
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
