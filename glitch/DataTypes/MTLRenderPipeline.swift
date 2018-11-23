//
//  MTLRenderPipeline.swift
//  glitch
//
//  Created by Valentin Dufois on 11/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import Metal

struct MTLRenderPipeline {
	// MARK: - Render pipeline properties

	/// The render pipeline itself
	private var _renderPipelineState:MTLRenderPipelineState

	/// The name of the vertex function
	private var _vertexFunctionName:String

	/// The name of the fragment function
	private var _fragmentFunctionName:String

	// MARK: - Initializer

	/// Create a render pipeline with the given shader functions names
	///
	/// - Parameters:
	///   - vertexShader: Vertex function name
	///   - fragmentShader: Fragment function name
	init(vertexShader: String, fragmentShader: String) {

		_vertexFunctionName = vertexShader
		_fragmentFunctionName = fragmentShader

		// Create the render pipeline descriptor
		let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
		pipelineStateDescriptor.vertexFunction = MetalEngine.instance.makeShaderFunction(vertexShader)
		pipelineStateDescriptor.fragmentFunction = MetalEngine.instance.makeShaderFunction(fragmentShader)
		pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

		_renderPipelineState = try! MetalEngine.instance.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
	}

	// MARK: - Accessible properties

	// The name of the vertex function
	var vertexFunction:String { get { return _vertexFunctionName } }

	// The name of the vertex function
	var fragmentFunction:String { get { return _fragmentFunctionName } }

	// The pipeline
	var pipeline:MTLRenderPipelineState { get { return _renderPipelineState } }
	
}
