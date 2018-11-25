//
//  ImageClampingSceneController.swift
//  glitch
//
//  Created by Valentin Dufois on 14/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import Cocoa
import Metal
import simd

class ImageClampingSceneController: NSViewController, NSWindowDelegate {
	// MARK: Metal properties
	// The primitive we're gonna draw
	var plane:PlaneMesh!

	var squarePosition:float2!
	var squareSize:CGSize!

	var metal = MetalEngine.instance

	override func viewDidLoad() {
		super.viewDidLoad()

		print("ImageClampingSceneController")

		view.autoresizingMask = [.width, .height]
		view.wantsLayer = true

		NotificationCenter.default.addObserver(self, selector: #selector(onImageUpdate), name: Notifications.openFile.name, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(onSave), name: Notifications.saveRender.name, object: nil)
	}

	override func viewDidAppear() {
		// Do any additional setup after loading the view.
		initMetal();

		view.window?.delegate = self

		squarePosition = float2(x: Float(metal.frame.size.width - 100) / 2.0, y: Float(metal.frame.size.height - 100) / 2.0)
		squareSize = CGSize(width: 100, height: 100)
	}

	override func viewWillDisappear() {	}

	// MARK: User events
	override func scrollWheel(with event: NSEvent) {
		let scrollAmountY = Float(event.scrollingDeltaY) * 0.75
		let scrollAmountX = Float(event.scrollingDeltaX) * 0.75

		squarePosition.x += scrollAmountX
		squarePosition.y += scrollAmountY

		squarePosition.x = simd_clamp(squarePosition.x, Float(0.0), metal.frame.size.widthFloat - squareSize.widthFloat)
		squarePosition.y = simd_clamp(squarePosition.y, Float(0.0), metal.frame.size.heightFloat - squareSize.heightFloat)
	}

	override func magnify(with event: NSEvent) {
		let scrollAmountZ = event.deltaZ
		squareSize.width += scrollAmountZ
		squareSize.height += scrollAmountZ

		squareSize.width = CGFloat(simd_max(1, squareSize.widthFloat))
		squareSize.height = CGFloat(simd_max(1, squareSize.heightFloat))

		squarePosition.x -= Float(scrollAmountZ) / 2
		squarePosition.y -= Float(scrollAmountZ) / 2
	}

	func windowDidResize(_ notification: Notification) {
		metal.update(frame: metal.frame)
		//plane?.size = metal.frame.size
		//plane?.position.x = metal.frame.size.widthFloat / 2.0
		//plane?.position.y = metal.frame.size.heightFloat / 2.0
	}

	private func initMetal() {
		metal.setLayer(layer: view.layer!)

		// Init our plane
		plane = PlaneMesh(x: view.frame.size.widthFloat / 2,
						  y: view.frame.size.heightFloat / 2,
						  width: Float(metal.frame.width),
						  height: Float(metal.frame.height))

		plane.fragmentShader = .function("mesh_fragment_square_clamping")
		plane.commit()

		let fileURL = Bundle.main.url(forResource: "001", withExtension: ".jpeg")!

		NotificationCenter.default.post(name: .init("userOpenedFile"), object: fileURL.relativePath)

		metal.setupRenderLoop(framerate: 5, renderMethod: render)
	}

	@objc func render() {
		// Update and send the line position
//		var uniforms = Uniforms()
//		uniforms.squarePosition = squarePosition
//		uniforms.squareSize = float2(squareSize.widthFloat, squareSize.heightFloat)
//
//		metal.makeBuffer("uniforms", of: &uniforms, size: MemoryLayout<Uniforms>.stride)
//		plane.customUniforms = metal.buffer("uniforms")

		plane.render()
	}

	@objc func onImageUpdate(_ obj: NSNotification) {
		let pathString = obj.object as! String
		let newImagePath = URL(fileURLWithPath: pathString)

		plane.setTexture(fromURL: newImagePath)

		// Register oppened URL
		NSDocumentController.shared.noteNewRecentDocumentURL(newImagePath)

		squarePosition = float2(x: Float(metal.frame.size.width - 100) / 2.0, y: Float(metal.frame.size.height - 100) / 2.0)

		// Load image to get its dimensions
		let image = NSImage(byReferencing: newImagePath)

		if(image.size.width > image.size.height) {
			plane.size.width = view.frame.size.width
			plane.size.height = (view.frame.size.width / image.size.width) * image.size.height

			plane.position.x = 0.0
			plane.position.y = (view.frame.size.heightFloat - plane.size.heightFloat) / 2.0
		} else {
			plane.size.height = view.frame.size.height
			plane.size.width = (view.frame.size.height / image.size.height) * image.size.width

			plane.position.x = (view.frame.size.widthFloat - plane.size.widthFloat) / 2.0
			plane.position.y = 0.0
		}
	}

	@objc func onSave(_ obg: NSNotification) {
		metal.saveCurrentTexture()
	}
}
