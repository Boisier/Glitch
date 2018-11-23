//
//  glitchEffects.metal
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "glitchEffects.h"

using namespace metal;

float4 glitch_vertical_fragment (		  Vertex 		  frag,
								 		  float4		  currentColor,
								 constant Uniforms 		 * uniforms,
										  int			   cursorPosition,
										  texture2d<float> tex2D,
										  sampler          sampler2D,
								 constant WorldUniforms  * worldUniforms)
{
	int lineY = uniforms[cursorPosition].parametersValue.x;

	return tex2D.sample(sampler2D, float2(frag.uv.x, lineY / worldUniforms->resolution.y));
}

float4 image_clamping_fragment (		  Vertex 		  frag,
								 float4		  currentColor,
								 constant Uniforms 		 * uniforms,
								 int			   cursorPosition,
								 texture2d<float> tex2D,
								 sampler          sampler2D,
								 constant WorldUniforms  * worldUniforms)
{
	float2 sourceFragment;

	float squareSize = uniforms[cursorPosition].parametersValue.x;
	float2 squarePosition = uniforms[cursorPosition + 1].parametersValue.xy;

	// Frag X
	if(frag.position.x < squarePosition.x) {
		sourceFragment.x = squarePosition.x;
	} else if(frag.position.x > squarePosition.x + squareSize) {
		sourceFragment.x = squarePosition.x + squareSize;
	} else {
		sourceFragment.x = frag.position.x;
	}

	// Frag Y
	if(frag.position.y < squarePosition.y) {
		sourceFragment.y = squarePosition.y;
	} else if(frag.position.y > squarePosition.y + squareSize) {
		sourceFragment.y = squarePosition.y + squareSize;
	} else {
		sourceFragment.y = frag.position.y;
	}

	// Normalize coordinates
	sourceFragment.x /= worldUniforms->resolution.x;
	sourceFragment.y /= worldUniforms->resolution.y;

	float4 color = tex2D.sample(sampler2D, sourceFragment);
	return float4(color);
}
