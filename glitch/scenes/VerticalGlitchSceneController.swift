//
//  VerticalGlitchSceneController.swift
//  glitch
//
//  Created by Valentin Dufois on 07/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import Cocoa
import Metal
import simd

class VerticalGlitchSceneController: NSViewController, NSWindowDelegate {
	// MARK: Metal properties
	// The primitive we're gonna draw
	var plane:PlaneMesh!

	var lineY:Float!

	var metal = MetalEngine.instance

	override func viewDidLoad() {
		super.viewDidLoad()

		print("VerticalGlitchSceneController")

		view.autoresizingMask = [.width, .height]

		NotificationCenter.default.addObserver(self, selector: #selector(onImageUpdate), name: NSNotification.Name("userOpenedFile"), object: nil)

		initMetal()
	}

	override func viewDidAppear() {
		view.window?.delegate = self

		lineY = Float(view.frame.size.height) / 2;
	}

	// MARK: User events
	override func scrollWheel(with event: NSEvent) {
		let scrollAmount = Float(event.scrollingDeltaY) * -1
		lineY = simd_clamp(lineY! + scrollAmount, 0, Float(view.frame.size.height))
	}

	func windowDidResize(_ notification: Notification) {
		metal.update(frame: view.layer!.frame)
		plane?.size = view.layer!.frame.size
		plane?.position.x = view.layer!.frame.size.widthFloat / 2.0
		plane?.position.y = view.layer!.frame.size.heightFloat / 2.0
	}

	private func initMetal() {
		metal.setLayer(layer: view.layer!)

		// Init our plane
		plane = PlaneMesh(x: Float(view.layer!.frame.width / 2.0),
						  y: Float(view.layer!.frame.height / 2.0),
						  width: Float(view.layer!.frame.width),
						  height: Float(view.layer!.frame.height))

		plane.setTexture(fromURL: Bundle.main.url(forResource: "001", withExtension: ".jpeg")!)
		plane.fragmentShader = .function("mesh_fragment_vertical_glitch")

		plane.commit()

		metal.setupRenderLoop(framerate: 5, renderMethod: render)
	}

	@objc func render() {
		// Update and send the line position
//		var uniforms = Uniforms()
//		uniforms.lineY = lineY!
//
//		metal.makeBuffer("uniforms", of: &uniforms, size: MemoryLayout<Uniforms>.stride)
//		plane.customUniforms = metal.buffer("uniforms")

		plane.render()
	}

	@objc func onImageUpdate(_ obj: NSNotification) {
		let pathString = obj.object as! String
		let newImagePath = URL(fileURLWithPath: pathString)

		plane.setTexture(fromURL: newImagePath)

		let documentController = NSDocumentController.shared
		documentController.noteNewRecentDocumentURL(newImagePath)

		lineY = Float(metal.texture(plane._textureName!).height) / 2.0;
	}
}

