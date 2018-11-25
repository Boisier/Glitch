//
//  MetalHelper.swift
//  glitch
//
//  Created by Valentin Dufois on 08/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import Cocoa
import Metal
import MetalKit
import ImageIO

/// The Metal Engine is an overlay on top of Metal, allowing for easier use.
///
/// The goal of Metal Engine is to enable fast and efficient app developpement using metal
/// to render content.
class MetalEngine {

	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:MetalEngine?

	/// Mark init as private to prevent oustide init
	private init() { setup() }

	/// get an instance of the engine. Instanciate if needed.
	static var instance:MetalEngine {
		get {
			guard _instance == nil else { return _instance! }

			_instance = MetalEngine()
			return _instance!
		}
	}


	// ////////////////////
	// MARK: Engine states

	/// Tell if the setup method as been called
	private var _initialized:Bool = false

	/// Tell if we are currently inside a render pass
	private var _inRenderPass = false

	// //////////////////////
	// MARK: Main Properties

	/// The device representing the GPU
	private var _device:MTLDevice!

	/// The parent layer to which the metal layer will attach
	private var _parentLayer:CALayer!

	/// The Layer on wich the metal frame will be printed
	private var _metalLayer:CAMetalLayer!

	/// Our command queue, used to send command to the GPU
	private var _commandQueue:MTLCommandQueue!


	// /////////////////////////
	// MARK: Shaders properties

	/// The library used to get shader functions
	private var _defaultLibrary:MTLLibrary!

	/// Stored render pipelines
	private var _renderPipelines: Dictionary<String, MTLRenderPipelineState> = Dictionary<String, MTLRenderPipelineState>();

	/// Stored compute pipelines
	private var _computePipelines: Dictionary<String, MTLComputePipelineState> = Dictionary<String, MTLComputePipelineState>();

	var computePipelines:Dictionary<String, MTLComputePipelineState> { return _computePipelines }

	/// Stored vertex shaders functions
	private var _shadersFunctions:Dictionary<String, MTLFunction> = Dictionary<String, MTLFunction>();



	// /////////////////////////////
	// MARK: App content properties

	/// All the app's buffer, accessible by names
	private var _buffers:Dictionary<String, MTLBuffer> = Dictionary<String, MTLBuffer>()

	/// All the app's textures, accessibles by URL
	private var _textures:Dictionary<URL, MTLTexture> = Dictionary<URL, MTLTexture>()

	/// Links between arbitrary names and textures URL
	///
	/// This is used to allow naming of textures, and multiple reference to a unique texture
	private var _texturesNames:Dictionary<String, URL> = Dictionary<String, URL>()

	// /////////////////////////////
	// MARK: Render pass properties

	/// Command buffer used for a render pass
	private var _commandBuffer:MTLCommandBuffer? = nil

	/// The current render pass descriptor
	private var _renderPassDescriptor:MTLRenderPassDescriptor? = nil

	/// The drawable used for the current render pass
	private var _drawable:CAMetalDrawable? = nil


	// /////////////////////////////
	// MARK: Rendering loop settings

	private var _framerate:Int?

	/// Timer used when a rendering loop is set up
	private var _timer:Timer? = nil

	/// Method called on each render loop
	private var _renderMethod:(() -> Void)?

	/// Color used to clear the screen on each frame (default is black)
	private var _clearColor:MTLClearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

	var hasRenderLoop:Bool { return _timer != nil }


	// /////////////////////////////////
	// MARK: World projection properties

	private var _viewport:MTLViewport!

	/// Projection matrix used to render elements
	private var _projectionMatrix:float4x4!

	/// The buffer holding the world uniforms for the current pass
	private var _worldUniformsBuffer:MTLBuffer!


	// ////////////////////
	// MARK: Miscellenaous

	private var _saveTextureOnRender:Bool = false
}


// MARK: - Computed properties
extension MetalEngine {
	/// Tell if the engine has been initialize
	var initialized: Bool {
		get { return _initialized }
	}

	/// Give the metal layer resolution
	var resolution: float2 {
		get { return float2(Float(_metalLayer.frame.width), Float(_metalLayer.frame.height)) }
	}

	/// Gives external access to the render pipeline
	var device: MTLDevice {
		get { return _device }
	}

	/// Color used to clear the screen on each frame (default is black)
	var clearColor:MTLClearColor {
		get { return _clearColor }
		set { _clearColor = clearColor }
	}

	var worldUniforms:WorldUniforms {
		get {
			var worldUniforms = WorldUniforms()
			worldUniforms.resolution = self.resolution
			worldUniforms.projectionMatrix = _projectionMatrix

			return worldUniforms
		}
	}

	var worldUniformsBuffer:MTLBuffer { get { return _worldUniformsBuffer }}

	var frame:CGRect {
		get {
			return _metalLayer.frame
		}
		set {
			makeMetalLayer(frame)
		}
	}
}

// MARK: - Metal Engine initialization & layer
extension MetalEngine {
	/// This methods will add a Metal surface to the given layer.
	///
	/// The surface will have the same dimension as the layer.
	///
	/// - Parameter parentLayer: The parent layer for the metal surface
	func setup() -> Void {

		// Make sure the engine isn't already initialized
		guard !self.initialized else { return }

		// Set up our device
		_device = MTLCreateSystemDefaultDevice()

		// Set up our command queue (used to send instructions to the GPU)
		_commandQueue = _device.makeCommandQueue()

		// Set up our library for querying shaders
		_defaultLibrary = _device.makeDefaultLibrary()!

		// Register event listener for various application state update
		registerEventListeners()

		// Finaly, mark the engine as initialized
		_initialized = true;
	}

	func setLayer(layer parentLayer: CALayer) -> Void {
		// Set up our layer
		_parentLayer = parentLayer
		makeMetalLayer(parentLayer.frame)

		// set our render environnement
		onFrameResize()

		// Initialize the world uniforms buffer
		var wU = self.worldUniforms
		_worldUniformsBuffer = makeBuffer(of: &wU, size: MemoryLayout<WorldUniforms>.stride)
	}

	func makeMetalLayer(_ frame: CGRect) -> Void {
		// Set up our layer
		let metalLayer = CAMetalLayer()
		metalLayer.device = _device
		metalLayer.pixelFormat = .bgra8Unorm
		metalLayer.framebufferOnly = false
		metalLayer.frame = frame
		metalLayer.drawableSize = frame.size

		if(_metalLayer != nil) {
			_parentLayer.replaceSublayer(_metalLayer, with: metalLayer)
		} else {
			_parentLayer.addSublayer(metalLayer)
		}

		_metalLayer = metalLayer

	}

	/// Generate a renderpipeline for the given shader methods and store it under the given name
	///
	/// - Parameters:
	///   - named: Name to give to the render pipeline
	///   - vertexShader: Name of the vertex shader method
	///   - fragmentShader: Name of the fragment shader method
	func createRenderPipeline(_ name: String, vertexShader: String, fragmentShader: String) -> Void {
		// Create our Render Pipeline (~OpenGL program~)

		// Describe our pipeline state
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = makeShaderFunction(vertexShader)
		pipelineStateDescriptor.fragmentFunction = makeShaderFunction(fragmentShader)
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

		// Finally, build our pipeline using the descriptor
		_renderPipelines[name] = try! _device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
	}


	/// Generate a compute pipeline with the given function
	///
	/// - Parameters:
	///   - name: Name to give to the pipeline. Will be used for retrieval
	///   - computeFunction: Name of the kernel function
	func makeComputePipeline(_ name: String, computeFunction: String) -> Void {
		do {
			let function = makeShaderFunction(computeFunction)
			_computePipelines[name] = try _device.makeComputePipelineState(function: function)
		} catch {
			fatalError(error.localizedDescription)
		}
	}


	/// Create a shader function by its name
	///
	/// Functions created are stored in the engine to allow for reusability.
	///
	/// - Parameter name: Name of the Metal Shader function
	/// - Returns: The created shader function
	func makeShaderFunction(_ name: String) -> MTLFunction {
		guard let shader = _shadersFunctions[name] else {
			_shadersFunctions[name] = _defaultLibrary.makeFunction(name: name)
			return _shadersFunctions[name]!
		}

		return shader
	}


	/// Update the metal layer to the given frame
	///
	/// - Parameter newFrame: The new frame to fit
	func update(frame newFrame: CGRect) {
		_metalLayer.frame = newFrame
		_metalLayer.drawableSize = newFrame.size

		onFrameResize()
	}
}


// MARK: - Buffer related methods
extension MetalEngine {
	/// Generate a buffer with the given content and stored with the given name.
	/// This will overwrite any buffer with the same name.
	///
	/// - Parameters:
	///   - name: Name of the buffer
	///   - content: Content of the buffer
	///   - size: Size of the buffer
	func makeBuffer(_ name: String, of content:UnsafeRawPointer, size: Int) -> Void {
		// Generate and store the buffer
		let buffer = makeBuffer(of: content, size: size)
		_buffers[name] = buffer
	}

	/// Generate a buffer with the given data. This buffer is NOT stored in the engine.
	///
	/// - Parameters:
	///   - content: Data to put in the buffer
	///   - size: Size of the given data
	/// - Returns: The created buffer
	func makeBuffer(of content:UnsafeRawPointer, size: Int) -> MTLBuffer {
		return _device.makeBuffer(bytes: content, length: size, options: [])!
	}


	/// Replace the given buffer content with the one given
	///
	/// - Parameters:
	///   - buffer: Buffer to update
	///   - content: Content to put in the buffer
	///   - size: Size of the new content (must be the same a the buffer current size)
	func update(buffer: MTLBuffer, withContent content: UnsafeRawPointer, ofSize size: Int) {
		buffer.contents().copyMemory(from: content, byteCount: size)
	}

	/// Retrieve a buffer by its name. This will crash if the buffer does not exist.
	///
	/// - Parameter name: Name of the buffer
	/// - Returns: The buffer
	func buffer(_ name: String) -> MTLBuffer {
		return _buffers[name]!
	}
}


// MARK: - Texture handling methods
extension MetalEngine {
	/// Loads an image as a texture by its url. The texture can then be used using the given name.
	///
	/// If the given URL matches an already loaded texture, the texture will not be loaded again. Instead, an alias for the texture will be used.
	///
	/// - Parameters:
	///   - name: Name to give to the texture
	///   - url: URL to the texture
	func storeTexture(_ name: String, at url: URL) -> Void {
		// Check if URL is already loaded
		guard _textures.index(forKey: url) == nil else {
			// Url already loaded, just add an alias
			_texturesNames[name] = url
			return
		}

		// Store the texture
		_textures[url] = loadTexture(at: url)
		_texturesNames[name] = url
	}

	func loadTexture(at url: URL) -> MTLTexture {
		// Load and resize the texture
		let sourceImage = NSImage(byReferencing: url).resize(to: NSSize(width: 1000, height: 1000))

		let loader = MTKTextureLoader(device: _device)
		let options = [MTKTextureLoader.Option.SRGB: false]
		return try! loader.newTexture(data: sourceImage.tiffRepresentation!, options: options)
	}

	func makeShaderTexture(_ name: String, from sourceTexture: MTLTexture) -> Void {
		let descriptor = MTLTextureDescriptor.texture2DDescriptor(
			pixelFormat: .bgra8Unorm,
			width: sourceTexture.width,
			height: sourceTexture.height,
			mipmapped: false)
		descriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue)

		let texture = _device.makeTexture(descriptor: descriptor)

		// Store the texture
		_textures[URL(string: name)!] = texture
		_texturesNames[name] = URL(string: name)!

	}

	/// Gets a texture by its name. Fails if the texture does not exist
	///
	/// - Parameter name: Name of the texture
	/// - Returns: The texture
	func texture(_ name: String) -> MTLTexture{
		return _textures[_texturesNames[name]!]!
	}

	/// Remove the names texture.
	///
	/// - Warning: The texture will only be freed from memory if all the aliases to it are removed.
	/// - Parameter name: Name of the texture to remove
	func removeTexture(_ name:String) {
		// Make sure the texture exist
		guard let texturePath = _texturesNames[name] else { return }

		// Remove it's name
		_texturesNames.removeValue(forKey: name)

		// Make sure the texture is not used elsewhere before deallocating it
		let filteredNames = _texturesNames.filter{ $1 == texturePath }
		guard filteredNames.count == 0 else { return }

		// Safely remove the texture
		_textures.removeValue(forKey: texturePath)
	}

	/// Gives a default sampler descriptor for texture handling
	///
	/// - Returns: The sampler descriptor
	func defaultSampler() -> MTLSamplerState {
		let sampler = MTLSamplerDescriptor()
		sampler.minFilter             = MTLSamplerMinMagFilter.nearest
		sampler.magFilter             = MTLSamplerMinMagFilter.nearest
		sampler.mipFilter             = MTLSamplerMipFilter.nearest
		sampler.maxAnisotropy         = 1
		sampler.sAddressMode          = MTLSamplerAddressMode.clampToEdge
		sampler.tAddressMode          = MTLSamplerAddressMode.clampToEdge
		sampler.rAddressMode          = MTLSamplerAddressMode.clampToEdge
		sampler.normalizedCoordinates = true
		sampler.lodMinClamp           = 0
		sampler.lodMaxClamp           = Float.greatestFiniteMagnitude
		return _device.makeSamplerState(descriptor: sampler)!
	}
}


// MARK: - Rendering methods
extension MetalEngine {
	/// Begin a render pass. This gets the next drawable and create a command buffer
	func startRenderPass() -> Void {
		// Check we are not already in a render pass
		guard !_inRenderPass else { return }

		// Make sure the metal engin is properly intialized
		guard _commandQueue != nil else { fatalError("Cannot start a render pass if the MetalEngine is not setup") }

		// Get the next drawable (the surface on wich we can draw)
		guard let nextDrawable = _metalLayer.nextDrawable() else { fatalError("Could not get a drawable") }

		// Mark the render pass has started
		_inRenderPass = true

		// Store the current drawable
		self._drawable = nextDrawable

		// Tell how we want to handle our current drawing buffer
		_renderPassDescriptor = MTLRenderPassDescriptor()
		_renderPassDescriptor!.colorAttachments[0].texture = _drawable!.texture
		_renderPassDescriptor!.colorAttachments[0].loadAction = .clear
		_renderPassDescriptor!.colorAttachments[0].clearColor = _clearColor

		// Create a command buffer where we will put all our commands
		_commandBuffer = _commandQueue.makeCommandBuffer()!

		// Update the world uniforms buffer
		var wU = self.worldUniforms
		update(buffer: _worldUniformsBuffer, withContent: &wU, ofSize: MemoryLayout<WorldUniforms>.stride)
	}

	/// Gets a renderEncoder, used to send directive to the GPU. The methods must only be called inside a render pass
	/// The buffer (1) is pre-filled with the world uniforms.
	func getRenderEncoder() -> MTLRenderCommandEncoder {
		guard _inRenderPass else {
			fatalError("Cannot get a renderEncoder outside a render pass")
		}

		let renderEncoder = _commandBuffer!.makeRenderCommandEncoder(descriptor: _renderPassDescriptor!)!

		renderEncoder.setViewport(_viewport)

		return renderEncoder
	}

	func getComputeEncoder(_ name: String) -> MTLComputeCommandEncoder {
		guard _inRenderPass else {
			fatalError("Cannot get a renderEncoder outside a render pass")
		}

		let computeEncoder = _commandBuffer!.makeComputeCommandEncoder()!
		computeEncoder.setComputePipelineState(_computePipelines[name]!)

		return computeEncoder
	}


	/// Gets a renderEncoder, used to send directive to the GPU. The methods must only be called inside a render pass.
	///
	/// - Parameter pipeline: Name of the render pipeline to use for this encoder
	/// - Returns: A RenderEncoder
	func getRenderEncoder(withPipeline pipeline: String, withUniforms wrappedUniforms: MTLBuffer?) -> MTLRenderCommandEncoder {

		let renderEncoder = getRenderEncoder()
		
		renderEncoder.setRenderPipelineState(_renderPipelines[pipeline]!)

		if let uniforms = wrappedUniforms {
			renderEncoder.setVertexBuffer(uniforms, offset: 0, index: 2)
			renderEncoder.setFragmentBuffer(uniforms, offset: 0, index: 2)
		}

		return renderEncoder
	}

	/// Send all instructions to the GPU, and effectively terminate the current render pass
	func endRenderPass() -> Void {
		guard _inRenderPass else { fatalError("There is not active render pass") }

		if(_saveTextureOnRender) {
			doSaveCurrentTexture()
			_saveTextureOnRender = false
		}

		// Send our commands to the GPU
		_commandBuffer!.present(_drawable!)
		_commandBuffer!.commit()

		// Reset our internal state
		// _drawable = nil <-- Keep last drawable for screenshot if needed
		_renderPassDescriptor = nil
		_commandBuffer = nil

		_inRenderPass = false
	}
}


// MARK: - Rendering loop methods
extension MetalEngine {
	func setupRenderLoop(framerate: Int, renderMethod: @escaping () -> Void) {

		_framerate = framerate
		_renderMethod = renderMethod

		_timer = Timer.scheduledTimer(timeInterval: TimeInterval(1.0/Float(_framerate!)), target: self, selector: #selector(renderLoop), userInfo: nil, repeats: true)
	}

	@objc
	func renderLoop() {
		autoreleasepool {
			startRenderPass()

			_renderMethod?()

			endRenderPass()
		}
	}

	func stopRenderLoop() {
		_timer?.invalidate();
		_timer = nil
	}
}


// MARK: - Event listeners
extension MetalEngine {

	/// Register all events listener needed
	private func registerEventListeners() -> Void {
		// Application pause
		NotificationCenter.default.addObserver(self, selector: #selector(onPause), name: NSApplication.willHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onPause), name: NSApplication.willResignActiveNotification, object: nil)

		// Application resume
		NotificationCenter.default.addObserver(self, selector: #selector(onResume), name: NSApplication.didUnhideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onResume), name: NSApplication.didBecomeActiveNotification, object: nil)
	}

	/// Pause the current timer
	@objc
	private func onPause() {
		print("Pause app")

		// Stop the timer
		_timer?.invalidate()
		_timer = nil
	}

	/// Resume the timer if it had been paused or stopped
	@objc
	private func onResume() {
		print("Resume app")

		// Make sure there isn't already a timer running
		guard _timer == nil else { return }

		// Only start a timer back if we have a render method and a framerate set up
		guard _renderMethod != nil && _framerate != nil else { return }

		setupRenderLoop(framerate: _framerate!, renderMethod: _renderMethod!)
	}
}


// MARK: - Model projection, Matrix and stuff
extension MetalEngine {

	func onFrameResize() -> Void {
		_viewport = MTLViewport(originX: 0, originY: 0, width: Double(self.resolution.x), height: Double(self.resolution.y), znear: 0.0, zfar: 1.0)
		_projectionMatrix = makeOrthographicMatrix(left: 0, right: self.resolution.x, bottom: self.resolution.y, top: 0, near: 0.0, far: 1.0)
	}

	func makeOrthographicMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> float4x4 {
		return float4x4(
			[              2 / (right - left),                               0,                   0, 0],
			[                               0,              2 / (top - bottom),                   0, 0],
			[                               0,                               0,    1 / (far - near), 0],
			[ (left + right) / (left - right), (top + bottom) / (bottom - top), near / (near - far), 1]
		)

	}
}


// MARK: - Miscellenaous
extension MetalEngine {

	// Return the texture of the last used drawable
	///
	/// - Returns: The texture of the last drawable
	func getCurrentTexture() -> MTLTexture {
		guard _inRenderPass else { fatalError("Cannot get the current texture outside a render pass") }

		return _drawable!.texture
	}

	func saveCurrentTexture() {
		_saveTextureOnRender = true
		print("asked for save");
	}

	private func doSaveCurrentTexture() {
		let currentTexture = getCurrentTexture().toImage()!
		let image = NSImage(cgImage: currentTexture, size: _metalLayer.frame.size)

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd' - 'HH.mm.ss"

		let fileName = "glitch \(dateFormatter.string(from: Date())).png"
		var filePath = saveFolder
		filePath.appendPathComponent(fileName)

		print(filePath)

		image.writeToFile(file: filePath, usingType: .png)
	}


	private var saveFolder:URL {
		get {
			// Get Application support URL
			let folder = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!

			// Get and create if needed App folder in Application Support
			let glitchSaveFolder = folder.appendingPathComponent("glitch")

			do {
				try FileManager.default.createDirectory(at: glitchSaveFolder, withIntermediateDirectories: false, attributes: [:])
			} catch {
				// print("Glitch save folder already exist.")
			}

			return glitchSaveFolder
		}
	}
}
