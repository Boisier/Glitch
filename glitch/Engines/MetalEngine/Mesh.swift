//
//  Mesh.swift
//  glitch
//
//  Created by Valentin Dufois on 09/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

import Foundation
import Metal
import simd
import GLKit

/// A Mesh is a 2D/3D object represented by an array of vertices.
/// This class aims to allow for easy and efficient manipulation of meshs.
///
class Mesh {

	// /////////////////////////////
	// MARK: Mesh public properties

	/// Tell how the transformations are applied to the mesh
	///
	/// If set to .topFrontLeft, the mesh will be translated by a DEMI_UNIT on all axis
	/// half its height on Y before any transformation is applied
	var anchor: Mesh.AnchorPoint = .middle

	/// Types of primitives this mesh holds. Use .triangleStrip every time its possible. .triangle by default
	var primitiveType:MTLPrimitiveType = .triangle


	// //////////////////////////////
	// MARK: - Private properties

	/// Hold the vertices of the mesh
	private var _vertices:[Vertex]

	var vertices:[Vertex] { return _vertices }

	/// Tell if the vertices have been updated since the last time they were sent
	/// to the GPU
	private var _verticesUpdated:Bool

	/// Get the space needed to store the vertives.
	/// Used to allocate buffers
	private var _verticesSize:Int {
		get { return _vertices.count * MemoryLayout<Vertex>.stride }
	}

	/// The buffer holding this mesh vertices
	private var _buffer:MTLBuffer?

	var vertexBuffer:MTLBuffer? { return _buffer }

	// /////////////////////////////////////
	// MARK: Transformation properties

	/// Collection of transformations to apply on the mesh when rendering
	internal var _transformations:[float4x4] = [float4x4]()

	internal var _mergedTransformations:float4x4 {
		get { return _transformations.reduce(into: positionDeltaFromAnchor) { $0 *= $1 } }
		set {}
	}

	/// Buffer holdings the transformations to apply on the mesh
	private var _transformationsBuffer:MTLBuffer?

	var transformationsBuffer:MTLBuffer? { return _transformationsBuffer }


	// ////////////////////////////
	// MARK: Appearance properties

	/// The mesh render mode. This determine which fragment shader will be used on render
	var renderMode:Mesh.RenderMode = .colored

	/// Render color used on .colored meshs
	var _renderColor:MTLColor?

	/// Texture used on .textured meshs
	var _textureName:String?

	// //////////////////////////
	// MARK: - Render properties

	/// The vertex function to use to render this mesh
	var vertexShader:Mesh.VertexShaderFunction = .default

	/// The fragment function to use to render this mesh
	var fragmentShader:Mesh.FragmentShaderFunction = .default

	/// The render pipeline used by this mesh
	private var _renderPipeline:MTLRenderPipeline!

	var renderPipeline:MTLRenderPipelineState { return _renderPipeline.pipeline }

	var customUniforms: MTLBuffer?

	// /////////////////////
	// MARK: - Initializers

	/// generate a mesh with the given vertices
	///
	/// - Parameter vertices: Vertices of the mesh
	init(vertices: [Vertex]) {
		_vertices = vertices
		_verticesUpdated = true
	}
}


// MARK: - Appearance
extension Mesh {
	func setColor(_ color:MTLColor) {
		_renderColor = color

		self.renderMode = .colored
	}

	/// Load the given texture by its url, and set the mesh render mode to textured.
	///
	/// The Metal Engine Texture storage is used for the texture. The texture name is
	/// a string representation of the absolute URL.
	/// When assigning a texture on an already textured mesh, the texture is
	/// properly removed from the Metal Engine.
	///
	/// - Parameter url: URL of the texture
	func setTexture(fromURL url: URL) {
		// If there is already a texture, free it.
		if(_textureName != nil) {
			MetalEngine.instance.removeTexture(_textureName!)
			_textureName = nil
		}

		_textureName = url.absoluteString
		MetalEngine.instance.storeTexture(_textureName!, at: url)

		self.renderMode = .textured
	}
}


// MARK: - Buffers
extension Mesh {
	/// Create or update the vertices buffer with the mesh's buffers
	///
	/// This method prevent buffer update if the vertices haven't changed
	private func makeVerticesBuffer () {
		// If there is no buffer, create it
		guard let buffer = _buffer else {
			return createVerticesBuffer() }

		// Make sure the buffer capacity is enough for our data
		guard buffer.length >= _verticesSize else {
			return createVerticesBuffer() }

		// Make sure our data are different from the one already inside
		guard _verticesUpdated else { return }

		// Update the buffer content
		MetalEngine.instance.update(buffer: _buffer!, withContent: &_vertices, ofSize: _verticesSize)

		// Mark the buffer as up to date
		_verticesUpdated = false
	}

	// Create the vertices buffer and fills it with the mesh vertices
	private func createVerticesBuffer() {
		_buffer = MetalEngine.instance.makeBuffer(of: &_vertices, size: _verticesSize)
		_verticesUpdated = false
	}

	// Create or update the transformation matrix buffer
	private func makeTransformationsBuffer () {
		// If there is no buffer, create it
		guard let buffer = _transformationsBuffer else {
			createTransformationsBuffer()
			return
		}

		// Make sure the buffer capacity is enough for our data
		guard buffer.length >= MemoryLayout<float4x4>.stride else { return createTransformationsBuffer() }

		// Update the buffer content
		_transformationsBuffer?.contents().copyMemory(from: &_mergedTransformations, byteCount: MemoryLayout<float4x4>.stride)
	}

	private func createTransformationsBuffer() {
		_transformationsBuffer = MetalEngine.instance.makeBuffer(of: &_mergedTransformations, size: MemoryLayout<float4x4>.stride)
	}
}

// MARK: - Rendering
extension Mesh {

	/// Render the mesh on the screen
	func render() {
		// Start by making sure all our buffers are ready
		commit()

		// Get a render encoder
		let renderEncoder = MetalEngine.instance.getRenderEncoder()

		// Specify the render pipeline
		renderEncoder.setRenderPipelineState(_renderPipeline.pipeline)

		// Pass our vertices and their transformation
		renderEncoder.setVertexBuffer(_buffer, offset: 0, index: 0)

		// Pass our world transformations
		renderEncoder.setVertexBuffer(MetalEngine.instance.worldUniformsBuffer, offset: 0, index: 1)
		renderEncoder.setFragmentBuffer(MetalEngine.instance.worldUniformsBuffer, offset: 0, index: 1)

		// Pass our mesh transformations
		renderEncoder.setVertexBuffer(_transformationsBuffer, offset: 0, index: 2)

		// Send our appearences informations
		switch renderMode {
		case .textured:
			renderEncoder.setFragmentSamplerState(MetalEngine.instance.defaultSampler(), index: 0)
			renderEncoder.setFragmentTexture(MetalEngine.instance.texture(_textureName!), index: 0)
		case .colored: break
		}

		// Pass the custom uniforms if needed
		if let cUniforms = customUniforms {
			renderEncoder.setVertexBuffer(cUniforms, offset: 0, index: 3)
			renderEncoder.setFragmentBuffer(cUniforms, offset: 0, index: 2)
		}

		renderEncoder.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: _vertices.count)

		renderEncoder.endEncoding()
	}

	/// Initialize the mesh buffers and shaders if needed.
	///
	/// This method is called by default before each render. To prevent cluttering
	/// if a lot of mesh have to render simultaneously, call this method as soon
	/// as you've finished editing a mesh.
	func commit() {
		// Create or update if needed the vertices buffer
		makeVerticesBuffer()

		// Create or update if needed the transformations buffer
		makeTransformationsBuffer()

		// Create or update the render pipeline if needed
		makeRenderPipeline()
	}


	/// Create or update the render pipeline if needed
	func makeRenderPipeline() {
		let vertexFunction = vertexShader.function
		let fragmentFunction = fragmentShader.function

		// Is there already a render pipeline ?
		guard let pipeline = _renderPipeline else {
			_renderPipeline = MTLRenderPipeline(vertexShader: vertexFunction, fragmentShader: fragmentFunction)
			return
		}

		// Make sure the existing pipeline fits the current parameters
		guard pipeline.vertexFunction == vertexFunction && pipeline.fragmentFunction == fragmentFunction else {
			_renderPipeline = MTLRenderPipeline(vertexShader: vertexFunction, fragmentShader: fragmentFunction)
			return
		}
	}
}


// MARK: - Transformations
/// Mesh transformations are stored in an array and applied on the server side in the same
/// order as they were added.
/// As of now, you need to clear all transformations and add them again if you
/// want to edit them.
extension Mesh {
	/// This removes all transformations applied on the mesh
	func clearTransformations() {
		_transformations.removeAll()
	}

	/// Add a translation transformation on the mesh
	///
	/// - Parameters:
	///   - x: Translation on X axis
	///   - y: Translation on Y axis
	///   - z: Translation on Z axis
	func translate(x: Float, y: Float, z: Float) {
		let matrix:float4x4 = float4x4(matrix: GLKMatrix4MakeTranslation(x, y, z))
		_transformations.append(matrix)
	}

	/// Add a scale transformation on the mesh
	///
	/// - Parameters:
	///   - x: Scaling factor on X axis
	///   - y: Scaling factor on Y axis
	///   - z: Scaling factor on Z axis
	func scale(x: Float, y: Float, z: Float) {
		let matrix:float4x4 = float4x4(matrix: GLKMatrix4MakeScale(x, y, z))
		_transformations.append(matrix)
	}

	/// Add a X axis rotation transformation on the mesh
	///
	/// - Parameter x: Angle in degrees/radians ? dontknowdontcare
	func rotate(x: Float) {
		var matrix:float4x4 = matrix_identity_float4x4
		matrix[1, 1] = cos(x)
		matrix[2, 1] = -sin(x)
		matrix[1, 2] = sin(x)
		matrix[2, 2] = cos(x)

		_transformations.append(matrix)
	}

	/// Add a Y axis rotation transformation on the mesh
	///
	/// - Parameter y: Angle in degrees/radians ? dontknowdontcare
	func rotate(y: Float) {
		var matrix:float4x4 = matrix_identity_float4x4
		matrix[0, 0] = cos(y)
		matrix[2, 0] = sin(y)
		matrix[0, 2] = -sin(y)
		matrix[2, 2] = cos(y)

		_transformations.append(matrix)
	}

	/// Add a Z axis rotation transformation on the mesh
	///
	/// - Parameter z: Angle in degrees/radians ? dontknowdontcare
	func rotate(z: Float) {
		var matrix:float4x4 = matrix_identity_float4x4
		matrix[0, 0] = cos(z)
		matrix[1, 0] = -sin(z)
		matrix[0, 1] = sin(z)
		matrix[1, 1] = cos(z)

		_transformations.append(matrix)
	}


	var positionDeltaFromAnchor:float4x4 { get {
		var matrix:float4x4
		switch anchor {
		case .middle: matrix = matrix_identity_float4x4
		case .topFrontLeft:
			matrix = float4x4(matrix: GLKMatrix4MakeTranslation(Mesh.DEMI_UNIT, Mesh.DEMI_UNIT, Mesh.DEMI_UNIT))
		}

		return matrix
	} }
}


// MARK: - Mesh static values
extension Mesh {
	/// Base unit used for every mesh.
	///
	/// A mesh vertices coordinates should alwaus be between 0 and UNIT. The mesh
	/// should then be scaled to get the desired size
	static let UNIT:Float = 1.0
	static let DEMI_UNIT:Float = 0.5
}


// MARK: - Mesh properties enumerations
extension Mesh {
	/// Tell how the transformations have to behave on the mesh
	enum AnchorPoint {
		case middle
		case topFrontLeft
	}

	enum RenderMode {
		case colored
		case textured
	}

	enum VertexShaderFunction {
		case `default`
		case function(_ function: String)

		var function:String { get {
			switch self {
			case .default:
				return "mesh_vertex_default"
			case .function(let function):
				return function
			}
		} }
	}

	enum FragmentShaderFunction {
		case `default`
		case function(_ function: String)

		var function:String { get {
			switch self {
			case .default:
				return "mesh_fragment_default"
			case .function(let function):
				return function
			}
		} }
	}
}
