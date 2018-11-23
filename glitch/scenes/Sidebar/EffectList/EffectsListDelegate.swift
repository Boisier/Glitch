//
//  EffectsListDelegate.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

//MARK: - Outline View Delegate methods
extension EffectsListScene: NSOutlineViewDelegate {
	/// Gives the view representing the given item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - tableColumn: Column to which this applies
	///   - item: Item we need the view for
	/// - Returns: The view for the item
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {

		guard let sidebarItem = item as? SideBarItem else { return nil }

		switch sidebarItem {
		case .section(_):
			return getSectionView(of: outlineView, forItem: sidebarItem)
		case .effect(let effectKey):
			return getEffectView(of: outlineView, for: effectKey)
		case .parameter(let parameterIndex, let effectKey):
			return getParameterView(of: outlineView, for: (effectKey, parameterIndex))
		}
	}

	/// Tells if the concerned item is a group item/section header
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - item: The concerned item
	/// - Returns: True if its a header, false otherwise
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		guard let sidebarItem = item as? SideBarItem else { return false }

		switch sidebarItem {
		case .section(_):
			return true
		default:
			return false
		}
	}

	/// Tell if the specified item should be selectable
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - item: The item
	/// - Returns: True if yess
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		guard let sidebarItem = item as? SideBarItem else { return false }

		switch sidebarItem {
		case .effect(_):
			return true
		default:
			return false
		}
	}

	/// Called when the selection on the outline view changed
	///
	/// - Parameter notification: The event notification
	func outlineViewSelectionDidChange(_ notification: Notification) {
		if _currentItem != nil {
			if case let .effect(effectKey) = _currentItem! {
				EffectsList.instance.effects[effectKey]!.isSelected = false
			}
		}

		let outlineView = notification.object as! NSOutlineView

		guard let _currentSelection = outlineView.item(atRow: outlineView.selectedRow) else {
			return
		}

		_currentItem = _currentSelection as? SideBarItem

		if case let .effect(effectKey) = _currentItem! {
			EffectsList.instance.effects[effectKey]!.isSelected = true
		}
	}
}


// MARK: - The views
extension EffectsListScene {
	/// Return the view for a section item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - item: The current item
	/// - Returns: The view
	private func getSectionView(of outlineView:NSOutlineView, forItem item: SideBarItem) -> NSTableCellView {
		let view:SidebarGlitchSection = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "glitchEffectSection"), owner: self) as! SidebarGlitchSection

		view.label!.stringValue = "Effets"

		return view
	}

	/// Return the view for an effect item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - effectIndex: The current item
	/// - Returns: The view
	private func getEffectView(of outlineView:NSOutlineView, for effectKey: Int) -> NSTableCellView? {
		// Get the view
		return EffectsList.instance.effects[effectKey]?.getEffectView(for: outlineView)
	}

	/// Return the view for a parameter item
	///
	/// - Parameters:
	///   - outlineView: The OutlineView to which this applies
	///   - indexes: The current item
	/// - Returns: The view
	private func getParameterView(of outlineView:NSOutlineView, for indexes: (Int, Int)) -> NSTableCellView? {
		// Get the view
		return EffectsList.instance.effects[indexes.0]?.getParameterView(for: outlineView, parameter: indexes.1)
	}
}
