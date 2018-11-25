//
//  MainGlitchScene.swift
//  glitch
//
//  Created by Valentin Dufois on 18/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit
import simd

class RenderScene: NSViewController, NSWindowDelegate {

	var plane:PlaneMesh!
	var currentTextureDimensions:NSSize!

	var metal = MetalEngine.instance

	private var _inRender:Bool = false
}

// MARK: - View Lyfecycle
extension RenderScene {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Set up our view
		view.autoresizingMask = [.width, .height]
		view.wantsLayer = true

		// Register our observers
		NotificationCenter.default.addObserver(self, selector: #selector(onImageUpdate), name: Notifications.openFile.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onSave), name: Notifications.saveRender.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(startLoop), name: Notifications.startRenderLoop.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(stopLoop), name: Notifications.stopRenderLoop.name, object: nil)
	}

	override func viewDidAppear() {
		// Finish setting up our view
		view.window?.delegate = self

		// Set up metal
		metal.setLayer(layer: view.layer!)

		// Set up our plane
		plane = PlaneMesh(x: view.frame.size.widthFloat / 2.0,
						  y: view.frame.size.heightFloat / 2.0,
						  width: 0.0,
						  height: 0.0)
		plane.fragmentShader = .function("mesh_fragment_glitch")

		//Load our first image
		let fileURL = Bundle.main.url(forResource: "001", withExtension: ".jpeg")!
		NotificationCenter.default.post(name: Notifications.openFile.name, object: fileURL.relativePath)

		startLoop()
	}

	func windowDidResize(_ notification: Notification) {
		metal.update(frame: view.layer!.frame)

		sizePlaneToFit()

		NotificationCenter.default.post(name: Notifications.windowResized.name, object: nil)
	}
}


// MARK: - User event
extension RenderScene {
	override func scrollWheel(with event: NSEvent) {
		NotificationCenter.default.post(name: Notifications.userScrolled.name, object: event)
	}

	override func magnify(with event: NSEvent) {
		NotificationCenter.default.post(name: Notifications.userMagnified.name, object: event)
	}

	@objc
	func onImageUpdate(_ obj: NSNotification) {
		let pathString = obj.object as! String
		let newImagePath = URL(fileURLWithPath: pathString)

		// Load image to get its dimensions

		plane.setTexture(fromURL: newImagePath)
		GlitchEngine.instance.setInput(texture: newImagePath)

		let image = NSImage(byReferencing: newImagePath)
		currentTextureDimensions = image.size

		// Register oppened URL
		NSDocumentController.shared.noteNewRecentDocumentURL(newImagePath)

		sizePlaneToFit()

		// If rendering is pause, let's force a render
		if(!metal.hasRenderLoop) {
			metal.startRenderPass()
			GlitchEngine.instance.renderWithEffects(plane)
			metal.endRenderPass()
		}
	}

	@objc
	func onSave() {
		metal.saveCurrentTexture()
	}

	@objc
	func startLoop() {
		metal.setupRenderLoop(framerate: 25, renderMethod: render)
	}

	@objc
	func stopLoop() {
		metal.stopRenderLoop()
	}
}


// MARK: - Render loop
extension RenderScene {
	func render() -> Void {
		GlitchEngine.instance.render(plane)
	}
}


// MARK: - Plane handling
extension RenderScene {
	func sizePlaneToFit() -> Void {
		plane.position.x = view.frame.size.widthFloat / 2.0
		plane.position.y = view.frame.size.heightFloat / 2.0

		if(currentTextureDimensions.width > currentTextureDimensions.height) {
			sizePlaneByWidth()

			if(plane.size.height > view.frame.size.height) {
				sizePlaneByHeight()
			}
		} else {
			sizePlaneByHeight()

			if(plane.size.width > view.frame.size.width) {
				sizePlaneByWidth()
			}
		}

		plane.commit()
	}

	private func sizePlaneByWidth() {
		plane.size.width = view.frame.size.width
		plane.size.height = (view.frame.size.width / currentTextureDimensions.width) * currentTextureDimensions.height
	}

	private func sizePlaneByHeight() {
		plane.size.height = view.frame.size.height
		plane.size.width = (view.frame.size.height / currentTextureDimensions.height) * currentTextureDimensions.width
	}
}
