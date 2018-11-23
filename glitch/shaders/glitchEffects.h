//
//  glitchEffects.h
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef glitchEffects_h
#define glitchEffects_h

#include <metal_stdlib>
#include <simd/simd.h>

#include "structures.h"

using namespace metal;

// ///////////////
// Shader methods

float4 glitch_vertical_fragment (		  Vertex 		  frag,
								 float4		  currentColor,
								 constant Uniforms 		 * uniforms,
								 int			   cursorPosition,
								 texture2d<float> tex2D,
								 sampler          sampler2D,
								 constant WorldUniforms  * worldUniforms);

float4 image_clamping_fragment (		  Vertex 		  frag,
								 float4		  currentColor,
								 constant Uniforms 		 * uniforms,
								 int			   cursorPosition,
								 texture2d<float> tex2D,
								 sampler          sampler2D,
								constant WorldUniforms  * worldUniforms);


#endif /* glitchEffects_h */
