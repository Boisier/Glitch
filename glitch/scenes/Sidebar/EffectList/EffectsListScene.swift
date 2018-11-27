//
//  SidebarController.swift
//  glitch
//
//  Created by Valentin Dufois on 17/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit


/// Represent the effects list on the side bar.
class EffectsListScene: NSViewController {

	/// Outline to the actual list element
	@IBOutlet
	var outlineView:NSOutlineView?

	/// The currently selected item, if any
	var _currentItem:SidebarItem? = nil

	/// Register observers for the view
	override func viewDidLoad() {
		// Add Observers
		NotificationCenter.default.addObserver(self, selector: #selector(onEffectAdded), name: Notifications.effectAdded.name, object: nil)
	}
}


// /////////////////////////
// MARK: - User interactions
extension EffectsListScene {

	/// Append a new effect to the list
	///
	/// - Parameter effectIndex: Index of the new effect
	@objc
	func onEffectAdded(_ obj: NSNotification) {
		outlineView?.insertItems(
			at: IndexSet(integer: EffectsList.instance.effects.count-1),
			inParent: nil, withAnimation: .slideDown)

		outlineView?.selectRowIndexes(.init(integer: outlineView!.numberOfRows-1), byExtendingSelection: false)

		outlineView!.expandItem(outlineView!.item(atRow: outlineView!.selectedRow))
	}

	/// Handle user click on the list
	///
	/// - Parameter outlineView: The OutlineView to which this applies
	@IBAction func userClick(_ outlineView: NSOutlineView) {
		guard outlineView.clickedRow >= 0 else {
			outlineView.deselectAll(nil)
			return
		}

		let item = outlineView.item(atRow: outlineView.clickedRow)

		if(!self.outlineView(outlineView, shouldSelectItem: item!)) {
			outlineView.deselectAll(nil)
			return
		}

		outlineView.expandItem(item)
	}

	/// Detect delete key event to remove effect
	///
	/// - Parameter event: Keyboard event
	override func keyDown(with event: NSEvent) {
		if event.keyCode != 51 { return }

		// Make sure there is a row selected
		guard outlineView?.selectedRow != -1 else { return }

		let itemIndex = outlineView!.selectedRow
		let item = outlineView!.item(atRow: itemIndex) as! SidebarItem

		if case let .effect(effectKey) = item {
			outlineView!.removeItems(
				at: IndexSet(arrayLiteral: EffectsList.instance.effectsKeys.firstIndex(of: effectKey)!),
				inParent: nil,
				withAnimation: .slideUp)

			EffectsList.instance.remove(effect: effectKey)
			_currentItem = nil
		}
	}
}
