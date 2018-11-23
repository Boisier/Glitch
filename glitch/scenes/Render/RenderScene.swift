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
}

// MARK: - View Lyfecycle
extension RenderScene {
	override func viewDidLoad() {
		super.viewDidLoad()

		// Set up our view
		view.autoresizingMask = [.width, .height]
		view.wantsLayer = true

		// Register our observers
		NotificationCenter.default.addObserver(self, selector: #selector(onImageUpdate), name: NSNotification.Name("userOpenedFile"), object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onSave), name: NSNotification.Name(rawValue: "userAskForSaving"), object: nil)
	}

	override func viewDidAppear() {
		// Finish setting up our view
		view.window?.delegate = self

		// Set up metal
		metal.setup(layer: view.layer!)

		// Set up our plane
		plane = PlaneMesh(x: view.frame.size.widthFloat / 2.0,
						  y: view.frame.size.heightFloat / 2.0,
						  width: 0.0,
						  height: 0.0)
		plane.fragmentShader = .function("mesh_fragment_glitch")

		//Load our first image
		let fileURL = Bundle.main.url(forResource: "001", withExtension: ".jpeg")!
		NotificationCenter.default.post(name: .init("userOpenedFile"), object: fileURL.relativePath)

		metal.setupRenderLoop(framerate: 25, renderMethod: render)
	}

	func windowDidResize(_ notification: Notification) {
		metal.update(frame: view.layer!.frame)

		sizePlaneToFit()

		NotificationCenter.default.post(name: NSNotification.Name("windowDidResized"), object: nil)
	}
}


// MARK: - User event
extension RenderScene {
	override func scrollWheel(with event: NSEvent) {
		NotificationCenter.default.post(name: NSNotification.Name("userScrollGlitch"), object: event)
	}

	override func magnify(with event: NSEvent) {
		NotificationCenter.default.post(name: NSNotification.Name("userMagnifyGlitch"), object: event)
	}

	@objc
	func onImageUpdate(_ obj: NSNotification) {
		let pathString = obj.object as! String
		let newImagePath = URL(fileURLWithPath: pathString)

		plane.setTexture(fromURL: newImagePath)

		// Register oppened URL
		NSDocumentController.shared.noteNewRecentDocumentURL(newImagePath)

		// Load image to get its dimensions
		let image = NSImage(byReferencing: newImagePath)
		currentTextureDimensions = image.size

		sizePlaneToFit()
	}

	@objc
	func onSave() {
		metal.saveCurrentTexture()
	}
}


// MARK: - Render loop
extension RenderScene {
	func render() -> Void {
		var effectsUniforms:[Uniforms] = EffectsList.instance.uniforms

		if(effectsUniforms.count == 0) {
			effectsUniforms.append(Uniforms(effectsCount: 0, effectsIdentifiers: 0, effectsParametersCount: 0, parametersValues: float4(0)))
		}

		let uniformsBuffer = metal.makeBuffer(
			of: &effectsUniforms,
			size: effectsUniforms.count * MemoryLayout<Uniforms>.stride)

		plane.customUniforms = uniformsBuffer
		plane.render()
	}

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
