//
//  glitchFragmentShader.metal
//  glitch
//
//  Created by Valentin Dufois on 23/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//


#include "Glitch.hpp"

kernel void glitch_engine_compute(
	                                        uint2                 pos [[thread_position_in_grid]] , // Our position in the texture
	constant                                 int2 * textureDimensions [[  buffer(0) ]],             // The texture dimensions
	constant                 GlitchEffectUniforms          * uniforms [[  buffer(1) ]],             // The current pass and effect informations
			 texture2d<float, access::read>           originalTexture [[ texture(0) ]],	            // Our input texture
			 texture2d<float, access::read_write>       bridgeTexture [[ texture(1) ]],             // Out output texture
			 texture2d<float, access::read_write>      bufferTextureA [[ texture(2) ]],             // Buffer texture A
             texture2d<float, access::read_write>      bufferTextureB [[ texture(3) ]],             // Buffer texture B
             texture2d<float, access::read_write>      bufferTextureC [[ texture(4) ]])             // Buffer texture C
{
	// Copy the current pixel to the bridge texture if this is the preparation pass
//	if(uniforms[0].currentEffect == 0) {
//		bridgeTexture.write(originalTexture.read(pos), pos);
//	}

	switch(uniforms[0].currentEffectIdentifier) {
		case GlitchEffects::imageClamping: {
			ImageClampingEffect effect = ImageClampingEffect();

			// Assign values to the effect
			effect.setCurrentPosition(pos);
			effect.setTextureDimensions(textureDimensions);
			effect.setUniforms(uniforms);
			effect.setOriginalTexture(originalTexture);
			effect.setBridgeTexture(bridgeTexture);
			effect.setBufferTextures(bufferTextureA, bufferTextureB, bufferTextureC);

			// Execute the effect
			effect.executeRenderPass(uniforms[0].currentPass);
			break;
		}
		case GlitchEffects::verticalGlitch: {
			VerticalGlitchEffect effect = VerticalGlitchEffect();

			// Assign values to the effect
			effect.setCurrentPosition(pos);
			effect.setTextureDimensions(textureDimensions);
			effect.setUniforms(uniforms);
			effect.setOriginalTexture(originalTexture);
			effect.setBridgeTexture(bridgeTexture);
			effect.setBufferTextures(bufferTextureA, bufferTextureB, bufferTextureC);

			// Execute the effect
			effect.executeRenderPass(uniforms[0].currentPass);
			break;
		}
		case GlitchEffects::pixelSorting: {
			PixelSortingEffect effect = PixelSortingEffect();

			// Assign values to the effect
			effect.setCurrentPosition(pos);
			effect.setTextureDimensions(textureDimensions);
			effect.setUniforms(uniforms);
			effect.setOriginalTexture(originalTexture);
			effect.setBridgeTexture(bridgeTexture);
			effect.setBufferTextures(bufferTextureA, bufferTextureB, bufferTextureC);

			// Execute the effect
			effect.executeRenderPass(uniforms[0].currentPass);
			break;
		}
		case GlitchEffects::smear: {
			SmearEffect effect = SmearEffect();

			// Assign values to the effect
			effect.setCurrentPosition(pos);
			effect.setTextureDimensions(textureDimensions);
			effect.setUniforms(uniforms);
			effect.setOriginalTexture(originalTexture);
			effect.setBridgeTexture(bridgeTexture);
			effect.setBufferTextures(bufferTextureA, bufferTextureB, bufferTextureC);

			// Execute the effect
			effect.executeRenderPass(uniforms[0].currentPass);
			break;
		}
	}
}
