//
//  SidebarController.swift
//  glitch
//
//  Created by Valentin Dufois on 19/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

/// The scene representing the sidebar, with the `EffectsListScene` and the Add Effect
/// popup list.
class SidebarScene: NSViewController {
	/// Outlet to the Effects Outline View
	@IBOutlet
	public var effectsOutlineView:NSView?

	/// The effects list scene
	public var effectsList:EffectsListScene?

	/// Outlet to the Add Effect popup
	@IBOutlet
	public var addEffectPopUp:NSPopUpButton?

	/// Init view, add observers and populate the popup list with all available effects
	override func viewDidLoad() {
		NotificationCenter.default.addObserver(self, selector: #selector(openPopup), name: Notifications.addEffect.name, object: nil)

		// Fill the list with the available effects
		addEffectPopUp!.addItems(withTitles: GlitchEngine.instance.availableEffects.map{ $0.name })

		GlitchEngine.instance.availableEffects.forEach { effect in
			addEffectPopUp?.addItem(withTitle: effect.name)
			addEffectPopUp?.itemArray.last!.representedObject = effect.identifier
		}
	}

	/// Catch the effects list view controller
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if let vc = segue.destinationController as? EffectsListScene,
			segue.identifier == "EffectsOutlineEmbedSegue" {
			effectsList = vc
		}
	}

	/// Allow the opening of the dropdown list using a keyboard shortcut. this is the observer
	@objc
	func openPopup() {
		addEffectPopUp!.becomeFirstResponder()
	}

	/// Add the selected effect on the popuplist to the list of effects
	///
	/// - Parameter popup: the popuplist
	@IBAction
	func addEffect(_ popup:NSPopUpButton) -> Void {
		// Make sure the header is not the one selected
		guard popup.indexOfSelectedItem != 0 else { return }

		// Add effect
		_ = EffectsList.instance.add(effectIdentifier: popup.selectedItem!.representedObject as! Int)

		popup.selectItem(at: 0)
	}
}
