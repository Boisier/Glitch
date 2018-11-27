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

/// The Render Scene, or Metal View, is in charge of rendering the current texture.
class RenderScene: NSViewController, NSWindowDelegate {
	/// The plane with the texture in it
	var plane:PlaneMesh!

	/// The current dimensions of the plane
	var currentTextureDimensions:NSSize!

	/// Convenient access to the metal engine
	private var _metal = MetalEngine.instance
}

// MARK: - View Lyfecycle
extension RenderScene {
	/// Called when the view is loaded. Sets its properties and register its observers
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

	/// Called when the view appeared, initialize the metal engine and start the rendering loop
	override func viewDidAppear() {
		// Finish setting up our view
		view.window?.delegate = self

		// Set up metal
		_metal.setLayer(layer: view.layer!)

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

	/// Called when the window resized, update the plane to fit the new dimensions
	/// and send a windowResized notification.
	///
	/// - Parameter notification: The window resized notification
	func windowDidResize(_ notification: Notification) {
		_metal.update(frame: view.layer!.frame)

		sizePlaneToFit()

		NotificationCenter.default.post(name: Notifications.windowResized.name, object: nil)
	}
}


// MARK: - User event
extension RenderScene {
	/// Called everytime the user scrolls on the render. Sends a userScrolled notification
	///
	/// - Parameter event: The scroll event
	override func scrollWheel(with event: NSEvent) {
		NotificationCenter.default.post(name: Notifications.userScrolled.name, object: event)
	}

	/// Called everytime the user magnifies on the render. Sends a userScrolled notification
	///
	/// - Parameter event: The magnify event
	override func magnify(with event: NSEvent) {
		NotificationCenter.default.post(name: Notifications.userMagnified.name, object: event)
	}

	/// Called when the user wants to open an image
	///
	/// - Parameter obj: The notification with the image url as a String as the object
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
		if(!_metal.hasRenderLoop) {
			_metal.startRenderPass()
			GlitchEngine.instance.renderWithEffects(plane)
			_metal.endRenderPass()
		}
	}

	/// Called when the user wants to save the texture
	@objc
	func onSave() {
		_metal.saveCurrentTexture()

		if _metal.hasRenderLoop { return }

		_metal.startRenderPass()
		GlitchEngine.instance.renderWithEffects(plane)
		_metal.endRenderPass()
	}

	/// Called when the user wants to start the render loop
	@objc
	func startLoop() {
		_metal.setupRenderLoop(framerate: 25, renderMethod: render)
	}

	/// Called when the user wants to stop the render loop
	@objc
	func stopLoop() {
		_metal.stopRenderLoop()
	}
}


// MARK: - Render loop
extension RenderScene {
	/// The render method called on each frame
	func render() -> Void {
		GlitchEngine.instance.render(plane)
	}
}


// MARK: - Plane handling
extension RenderScene {
	/// Resize the plane to fit the available space in the metal layer while keeping
	/// its texture aspect ratio
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

	/// Gets the new plane dimensions when sizing by width
	private func sizePlaneByWidth() {
		plane.size.width = view.frame.size.width
		plane.size.height = (view.frame.size.width / currentTextureDimensions.width) * currentTextureDimensions.height
	}

	/// Gets the new plane dimensions when sizing by height
	private func sizePlaneByHeight() {
		plane.size.height = view.frame.size.height
		plane.size.width = (view.frame.size.height / currentTextureDimensions.height) * currentTextureDimensions.width
	}
}
