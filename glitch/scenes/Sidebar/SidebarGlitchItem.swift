//
//  SidebarGlitchItem.swift
//  glitch
//
//  Created by Valentin Dufois on 18/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

class SidebarGlitchItem: NSTableCellView {
	@IBOutlet
	public var status:NSButton!

	private var _glitchEffect:GlitchEffect!

	func set(effect: GlitchEffect) {
		_glitchEffect = effect

		status.title = _glitchEffect.name
		status?.sizeToFit()
	}

	@IBAction func toggleState(_ sender: NSButton) {
		_glitchEffect.active = !_glitchEffect.active
	}
}
