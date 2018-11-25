//
//  GlitchEngine.swift
//  glitch
//
//  Created by Valentin Dufois on 20/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import AppKit
import simd

class GlitchEngine {

	// ////////////////////
	// MARK: Singleton

	/// Hold the singleton instance
	private static var _instance:GlitchEngine?

	/// get an instance of the engine. Instanciate if needed.
	static var instance:GlitchEngine {
		get {
			guard _instance == nil else { return _instance! }

			_instance = GlitchEngine()
			return _instance!
		}
	}

	private var _metal:MetalEngine = MetalEngine.instance


	// /////////////////////////////////
	// MARK: Effects

	private var _availableEffects:[GlitchEffectDecoder]!

	var availableEffects:[GlitchEffectDecoder] {
		get { return _availableEffects! }
	}

	// /////////////////////
	// Rendering properties

	private let _computePipeline:String = "/glitch_engine/compute_pipeline"
	private let _computeFunction:String = "glitch_engine_compute"

	private let _textureName:String = "/glitch_engine/input_texture"
	private var _textureSize:CGSize!

	private let _shaderBuffersNames = [
		"/glitch_engine/shader_buffer_a",	// The bridge texture between effects
		"/glitch_engine/shader_buffer_b",   //
		"/glitch_engine/shader_buffer_c",
		"/glitch_engine/shader_buffer_d",
	]

	// MARK: - Initialization
	/// mark init as private to prevent oustide init
	private init() {
		loadEffects()

		_metal.makeComputePipeline(_computePipeline, computeFunction: _computeFunction)

		NotificationCenter.default.addObserver(self, selector: #selector(resetBridgeTexture), name: Notifications.resetRender.name, object: nil)
	}
}


// MARK: - Effects
extension GlitchEngine {
	/// Load all available effects from the source JSON file
	private func loadEffects() -> Void {
		// Load the JSON file in a decoder
		let availableEffectsFilePath = Bundle.main.url(forResource: "availableEffects", withExtension: "json")!
		let availableEffectsJSON = try! Data(contentsOf: availableEffectsFilePath)

		let decoder = JSONDecoder()
		let availableEffectsToDecode:GlitchEffectsDecoderEncapsulation = try! decoder.decode(GlitchEffectsDecoderEncapsulation.self, from: availableEffectsJSON)

		_availableEffects = availableEffectsToDecode.effects
	}

	/// Create a new effect, add it to the list, and return its index
	///
	/// - Parameter effect: ID of the current effect
	/// - Returns: The newly created effect index
	func make(effect: Int) -> GlitchEffect {
		return _availableEffects!.filter{ $0.identifier == effect }.first!.decode()
	}
}



// MARK: - Rendering
extension GlitchEngine {

	/// Set the current input texture and resfresh the shader buffer.
	///
	/// - Parameter texture: URL to the input texture
	func setInput(texture: URL) -> Void {
		_metal.removeTexture(_textureName);
		_metal.storeTexture(_textureName, at: texture)

		_shaderBuffersNames.forEach {
			_metal.removeTexture($0);
			_metal.makeShaderTexture($0, from: _metal.texture(_textureName))
		}

		resetBridgeTexture()
	}

	@objc
	func resetBridgeTexture() {

		let sourceTexture = _metal.texture(_textureName)
		let bridgeTexture = _metal.texture(_shaderBuffersNames[0])
		bridgeTexture.replace(region: bridgeTexture.region,
							  mipmapLevel: 0,
							  withBytes: sourceTexture.bytes(),
							  bytesPerRow: bridgeTexture.width * 4)
	}

	/// Will render the given mesh by applying each effect on it one by one
	func render(_ mesh: Mesh) -> Void {
		prerenderEffects()
		renderWithEffects(mesh)
	}

	func prerenderEffects() {
		// The render of the effects will first take place in a compute encoder
		// One all effects have been applied, the render will be done on another render encoder.


		// Prepare the rendering loop
		let effectsCount = EffectsList.instance.effects.count
		var currentEffect = 0

		// Calculate threads dimensions
		let pipelineState = _metal.computePipelines[_computePipeline]!
		let w = pipelineState.threadExecutionWidth
		let h = pipelineState.maxTotalThreadsPerThreadgroup / w
		let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

		let threadsPerGrid = MTLSize(width: _metal.texture(_textureName).width,
									 height: _metal.texture(_textureName).height,
									 depth: 1)

		let computeEncoder = makeComputeEncoder()

		// Execute a compute for each effect
		EffectsList.instance.effects.forEach { key, effect in
			guard effect.active else { return }

			for currentPass in 0..<effect.renderPasses {
				// Get the effect uniforms for the current pass
				var effectUniforms:[GlitchEffectUniforms] = effect.parameters.map {
					GlitchEffectUniforms(
						currentEffect: simd_int1(currentEffect),
						currentEffectIdentifier: simd_int1(effect.identifier),
						effectsCount: simd_int1(effectsCount),
						currentPass: simd_int1(currentPass),
						effectPassCount: simd_int1(effect.renderPasses),
						parametersValues: $0.uniformValue)
				}

				// Make sure we have at least one row of informations
				if(effectUniforms.count == 0) {
					effectUniforms.append(GlitchEffectUniforms(
						currentEffect: simd_int1(currentEffect),
						currentEffectIdentifier: simd_int1(effect.identifier),
						effectsCount: simd_int1(effectsCount),
						currentPass: simd_int1(currentPass),
						effectPassCount: simd_int1(1),
						parametersValues: float4(0)))
				}

				// Bind the uniforms to the fragment shader
				computeEncoder.setBytes(&effectUniforms,
										length: MemoryLayout<GlitchEffectUniforms>.stride * effectUniforms.count,
										index: 1)

				// Execute the effect pass
				computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
			}

			currentEffect += 1
		}

		// End computing
		computeEncoder.endEncoding()
	}

	func renderWithEffects(_ mesh: Mesh) {
		// Make sure the mesh is ready to be rendered
		mesh.commit();

		// Start rendering
		let renderEncoder = _metal.getRenderEncoder()
		renderEncoder.setRenderPipelineState(mesh.renderPipeline)

		// Add the world uniforms
		renderEncoder.setVertexBuffer(_metal.worldUniformsBuffer, offset: 0, index: 1)
		renderEncoder.setFragmentBuffer(_metal.worldUniformsBuffer, offset: 0, index: 1)

		//Bind the vertices
		renderEncoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
		renderEncoder.setVertexBuffer(mesh.transformationsBuffer, offset: 0, index: 2)

		// Bind the texture
		renderEncoder.setFragmentTexture(_metal.texture( _shaderBuffersNames[0]), index: 0)
		renderEncoder.setFragmentSamplerState(_metal.defaultSampler(), index: 0)

		renderEncoder.drawPrimitives(type: mesh.primitiveType, vertexStart: 0, vertexCount: mesh.vertices.count)
		renderEncoder.endEncoding()
	}

	func makeComputeEncoder() -> MTLComputeCommandEncoder {
		let computeEncoder = _metal.getComputeEncoder(_computePipeline)

		// Bind the textures
		computeEncoder.setTextures([
			_metal.texture(_textureName),
			_metal.texture(_shaderBuffersNames[0]),
			_metal.texture(_shaderBuffersNames[1]),
			_metal.texture(_shaderBuffersNames[2]),
			_metal.texture(_shaderBuffersNames[3]),
			], range: 0..<5)

		// Bind the texture dimenions
		var textureDimensions = int2(
			Int32(_metal.texture(_textureName).width),
			Int32(_metal.texture(_textureName).height)
		)

		computeEncoder.setBytes(&textureDimensions, length: MemoryLayout<float2>.stride, index: 0)

		return computeEncoder
	}
}


// MARK: - Glitch Positionning Language (GLS) decoder
extension GlitchEngine {
	/// Decode a GLS string
	///
	/// All GLS String starts with an underscore (_)
	/// Standard format is _<Value>[:Modifier]
	/// Available values :
	///   * w -> Texture width
	///   * h -> Texture height
	///
	/// Available Modifiers :
	///   * center -> Divides the value by two
	///   * More to come
	///
	/// - Parameter gldString: The string to decode
	/// - Returns: The decoded value. Will return 0.0 in case of failure
	func decode(_ gldString: String) -> Float {
		guard gldString.first == "_" else { return 0.0 }

		var components = gldString.split(separator: "_")[0].split(separator: ":")

		var value:Float = 0.0

		// Set the used value
		switch components[0] {
		case "w": value = Float(_metal.texture(_textureName).width)
		case "h": value = Float(_metal.texture(_textureName).height)
		default: return 0.0 // Bad value
		}

		// Applies the modifiers
		components.removeFirst()
		components.forEach { modifier in
			switch modifier {
			case "center": value /= 2.0
			default: return
			}
		}

		return value
	}
}
