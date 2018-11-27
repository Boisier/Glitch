//
//  SplitViewController.swift
//  glitch
//
//  Created by Valentin Dufois on 17/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

/// used as the root of the main window, handles the sidebar behavior.
class SplitViewController: NSSplitViewController {
	/// Access to the sidebar `SplitViewitem`
	var sidebar:NSSplitViewItem!
	/// Access to the metalView `SplitViewItem`
	var metalView:NSSplitViewItem!

	/// The static width of the sidebar
	let sidebarWidth:CGFloat = 250;

	/// Called when the view just appeared, sets up its properties and register its observers.
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

		NotificationCenter.default.addObserver(self, selector: #selector(toggleSidebarObserver), name: Notifications.toggleSidebar.name, object: nil)
	}

	/// Tell the Split View Controller to toggle the sidebar
	///
	/// - Parameter sender: The event sender
	@objc func toggleSidebarObserver(_ sender: Any?) {
		toggleSidebar(sender)
	}
}
