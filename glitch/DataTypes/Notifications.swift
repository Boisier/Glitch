//
//  NSNotification.Name.swift
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit

protocol NotificationName {
	var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
	var name: Notification.Name {
		get {
			return Notification.Name(self.rawValue)
		}
	}
}

enum Notifications: String, NotificationName {
	// Action / Order sent
	case openFile
	case toggleSidebar
	case addEffect
	case saveRender
	case resetRender
	case stopRenderLoop
	case startRenderLoop

	// Events
	case windowResized
	case effectAdded
	case userScrolled
	case userMagnified
}
