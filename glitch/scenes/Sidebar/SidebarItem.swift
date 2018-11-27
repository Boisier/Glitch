//
//  SidebarItem.swift
//  glitch
//
//  Created by Valentin Dufois on 19/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

/// Tells the type of an item on the sidebar
enum SidebarItem {
	/// Section item
	/// - Parameter title: Title of the section
	case section(title: String)

	/// Effect item
	/// - Parameter key: Key of the represented effect in the `EffectsList.effects`
	case effect(key: Int)

	/// Effect item
	/// - Parameters:
	///   - index: Index of the parameter inside its parent effect
	///   - effectKey: Key of the represented effect in the `EffectsList.effects`
	case parameter(index: Int, effectKey: Int)
}
