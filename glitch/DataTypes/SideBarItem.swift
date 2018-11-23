//
//  SideBarItem.swift
//  glitch
//
//  Created by Valentin Dufois on 19/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation

enum SideBarItem {
	case section(title: String)
	case effect(key: Int)
	case parameter(index: Int, effectKey: Int)
}
