//
//  Glitch.hpp
//  glitch
//
//  Created by Valentin Dufois on 23/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef Glitch_h
#define Glitch_h

#include <metal_stdlib>
#include <simd/simd.h>

#include "GlitchEffectUniforms.hpp"

using namespace metal;

kernel void glitch_engine_compute(
								  uint2                 pos [[thread_position_in_grid]] , // Our position in the texture
								  constant                                 int2 * textureDimensions [[  buffer(0) ]],             // The texture dimensions
								  constant                 GlitchEffectUniforms          * uniforms [[  buffer(1) ]],             // The current pass and effect informations
								  texture2d<float, access::read>                 inTexture [[ texture(0) ]],	            // Our input texture
								  texture2d<float, access::read_write>          outTexture [[ texture(1) ]],             // Out output texture
								  texture2d<float, access::read_write>      bufferTextureA [[ texture(2) ]],             // Buffer texture A
								  texture2d<float, access::read_write>      bufferTextureB [[ texture(3) ]],             // Buffer texture B
								  texture2d<float, access::read_write>      bufferTextureC [[ texture(4) ]]);            // Buffer texture C

enum GlitchEffects {
	imageClamping = 1,
	verticalGlitch = 2,
	pixelSorting = 3,
	smear = 4
};

#include "Effects/VerticalGlitchEffect.hpp"
#include "Effects/ImageClampingEffect.hpp"
#include "Effects/PixelSortingEffect.hpp"
#include "Effects/SmearEffect.hpp"

#endif /* Glitch_h */
