//
//  ReplaceSegue.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

class ReplaceSegue: NSStoryboardSegue {
	override func perform() {
		if let src = self.sourceController as? NSViewController,
			let dest = self.destinationController as? NSViewController,
			let window = src.view.window {
			// this updates the content and adjusts window size
			window.contentViewController = dest
		}
	}
}
