//
//  NSNotification.Name.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

enum Notifications: String {
	// ////////////////////
	// Action / Order sent

	/// The user wants to open file
	case openFile

	/// The user wants to toggle the sidebar
	case toggleSidebar

	/// The user wants to add an effect
	case addEffect

	/// The user wants to save the current render
	case saveRender

	/// The user wants to reset the current render
	case resetRender

	/// The user wants to stop the render loop
	case stopRenderLoop

	/// The user wants to start the render loop
	case startRenderLoop


	// ///////
	// Events

	/// The window has been resized
	case windowResized

	/// An effect has been added
	case effectAdded

	/// The user scrolled on the render view
	case userScrolled

	/// The user magnified on the render view
	case userMagnified


	/// Gives the current enum as a `Notification.Name`
	var name: Notification.Name { return Notification.Name(self.rawValue) }
}
