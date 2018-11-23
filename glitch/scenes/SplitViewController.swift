//
//  SplitViewController.swift
//  glitch
//
//  Created by Valentin Dufois on 17/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

class SplitViewController: NSSplitViewController {
	var sidebar:NSSplitViewItem!
	var metalView:NSSplitViewItem!

	let sidebarWidth:CGFloat = 250;

	override func viewDidAppear() {
		// Set up the split view
		splitView.dividerStyle = .thin

		// get conveniences access to the views
		sidebar = self.splitViewItems[0]
		metalView = self.splitViewItems[1]

		// Setting up sidebar
		sidebar.minimumThickness = sidebarWidth;
		sidebar.maximumThickness = sidebarWidth;
		sidebar.canCollapse = true
		sidebar.collapseBehavior = .preferResizingSplitViewWithFixedSiblings

		NotificationCenter.default.addObserver(self, selector: #selector(toggleSidebarObserver), name: NSNotification.Name(rawValue: "toggleSidebar"), object: nil)
	}

	@objc func toggleSidebarObserver(_ sender: Any?) {
		toggleSidebar(sender)
	}
}
