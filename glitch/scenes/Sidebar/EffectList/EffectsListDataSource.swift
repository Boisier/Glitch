//
//  EffectsListDataSource.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

// MARK: - Outline View Data Source
///
/// Methods called by the outline view to populate itself
extension EffectsListScene: NSOutlineViewDataSource {

	/// Tells the number of childrens of the given item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - item: The parent item. Nil for root component
	/// - Returns: The number if child items the given item has
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		guard let sidebarItem = item as? SidebarItem else { return EffectsList.instance.effects.count }

		switch sidebarItem {
		case .section(_):
			return 0
		case .effect(let effectIndex):
			return EffectsList.instance.effects[effectIndex]!.parameters.count
		case .parameter(_, _):
			return 0
		}
	}

	/// Gives the nth children of the specified item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - index: Index if the child to get
	///   - item: The parent item, nil for root component
	/// - Returns: The item
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		// If this is the root component, just returns the headers and effect names
		guard let sidebarItem = item as? SidebarItem else {
			return SidebarItem.effect(key: EffectsList.instance.effectsKeys[index])
		}

		switch sidebarItem {
		case .effect(let effectIndex):
			return SidebarItem.parameter(index: index, effectKey: effectIndex)
		default:
			return []
		}
	}

	/// Tell if the specified item is expandable
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - item: The concerned item
	/// - Returns: True if expandable, false otherwise
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		guard let sidebarItem = item as? SidebarItem else { return false }

		switch sidebarItem {
		case .section(_):
			return false
		case .effect(_):
			return true
		case .parameter(_, _):
			return false
		}
	}

	/// Gives the value of the specified item for the specified column
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - tableColumn: The column to give the value for
	///   - item: Current item
	/// - Returns: The item value at the specified column
	func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
		guard let sidebarItem = item as? SidebarItem else { return nil }

		switch sidebarItem {
		case .section(_):
			return nil
		case .effect(_):
			return item
		case .parameter(_, _):
			return nil
		}
	}

	/// Gives the height of the row for the given item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - item: The item to give the needed height
	/// - Returns: The height needed for the item
	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		guard let sidebarItem = item as? SidebarItem else { return 1 }

		switch sidebarItem {
		case .section(_):
			return 20
		case .effect(_):
			return 30
		case .parameter(let parameterIndex, let effectIndex):
			switch EffectsList.instance.effects[effectIndex]!.parameters[parameterIndex].type {
			case .float, .int:
				return 27
			case .position2D:
				return 52
			case .position3D:
				return 79
			}
		}
	}
}
