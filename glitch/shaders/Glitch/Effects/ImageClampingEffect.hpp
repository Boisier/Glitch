//
//  ImageClampingEffect.hpp
//  glitch
//
//  Created by Valentin Dufois on 23/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef ImageClampingEffect_h
#define ImageClampingEffect_h

#include <metal_stdlib>
#include <simd/simd.h>

#include "../GlitchEffectUniforms.hpp"

using namespace metal;

class ImageClampingEffect {
	public:
	// Initialization methods

	ImageClampingEffect() {}

	inline void setCurrentPosition(const uint2 position) { _position = position; }
	inline void setTextureDimensions(constant int2 * dimensions) { _textureDimensions = dimensions; }

	inline void setUniforms(constant GlitchEffectUniforms * uniforms) { _uniforms = uniforms; }

	inline void setOriginalTexture(texture2d<float, access::read> originalTexture) {
		_originalTexture = originalTexture;
	}

	inline void setBridgeTexture(texture2d<float, access::read_write> bridgeTexture) {
		_bridgeTexture = bridgeTexture;
	}

	inline void setBufferTextures(texture2d<float, access::read_write> bufferTextureA,
								  texture2d<float, access::read_write> bufferTextureB,
								  texture2d<float, access::read_write> bufferTextureC) {
		_bufferTextureA = bufferTextureA;
		_bufferTextureB = bufferTextureB;
		_bufferTextureC = bufferTextureC;
	}

	void executeRenderPass(const int renderPass);

	private:

	/// Our position in the texture
	uint2 _position;

	/// The texture dimensions
	constant int2 * _textureDimensions;

	/// Our uniforms
	constant GlitchEffectUniforms * _uniforms;

	/// The bridge texture. That's our input, and our output
	texture2d<float, access::read_write> _bridgeTexture;

	/// The original texture, for reference if needed
	texture2d<float, access::read> _originalTexture;

	/// Buffer texture are available to store informations between passses
	texture2d<float, access::read_write> _bufferTextureA;
	texture2d<float, access::read_write> _bufferTextureB;
	texture2d<float, access::read_write> _bufferTextureC;

};

#endif /* ImageClampingEffect_h */
