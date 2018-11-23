//
//  Shaders.metal
//  glitch
//
//  Created by Valentin Dufois on 07/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef SHADERS
#define SHADERS

#include <metal_stdlib>
#include <simd/simd.h>

#include "structures.h"
#include "glitchEffects.h"
#include "PixelSorter.hpp"

using namespace metal;

vertex Vertex mesh_vertex_default(constant VertexIn         * vertices       [[ buffer(0) ]],
						   		  constant WorldUniforms    * worldUniforms  [[ buffer(1) ]],
								  constant float4x4 		* meshTransforms [[ buffer(2) ]],
						   		  unsigned int                vID            [[ vertex_id ]]) {

	Vertex out;
	float4x4 transformations = worldUniforms->projectionMatrix * *meshTransforms;
	out.position = transformations * float4(vertices[vID].position, 1.0);
	out.uv = vertices[vID].uv;
	return out;
}

fragment float4 mesh_fragment_default(         Vertex           frag          [[ stage_in   ]],
									  constant WorldUniforms  * wxorldUniforms [[  buffer(1) ]],
											   texture2d<float> tex2D         [[ texture(0) ]],
									           sampler          sampler2D     [[ sampler(0) ]])
{

	return tex2D.sample(sampler2D, frag.uv);
}

fragment float4 mesh_fragment_glitch(          Vertex           frag          [[ stage_in   ]],
									  constant WorldUniforms  * worldUniforms [[  buffer(1) ]],
									  constant Uniforms       * uniforms      [[  buffer(2) ]],
									           texture2d<float> tex2D         [[ texture(0) ]],
									           sampler          sampler2D     [[ sampler(0) ]],
									  device float4	  * shaderArray   [[  buffer(9) ]])
{
	int effectsCount = uniforms[0].effectsCount;
	int cursorPosition = 0;

	// Our starting point
	float4 texelColor = tex2D.sample(sampler2D, frag.uv);

	for(int i = 0; i < effectsCount; ++i) {
		int effectIdentifier = uniforms[cursorPosition].effectsIdentifiers;

		switch (effectIdentifier) {
			case 1:
				texelColor = image_clamping_fragment(
					frag,
					texelColor,
					uniforms,
					cursorPosition,
					tex2D,
					sampler2D,
					worldUniforms);
			break;
			case 2:
				texelColor = glitch_vertical_fragment(
					frag,
					texelColor,
					uniforms,
					cursorPosition,
					tex2D,
					sampler2D,
					worldUniforms);
			break;
			case 3:
				PixelSorter pixelSorter(
					uniforms,
					cursorPosition,
					tex2D,
					sampler2D,
					worldUniforms,
					shaderArray);
				texelColor = pixelSorter.forFragment(frag, texelColor);
			break;
		}

		cursorPosition += uniforms[cursorPosition].effectsParametersCount;
	}

	return texelColor;
}


//
//
//fragment float4 mesh_fragment_square_clamping(         Vertex           frag          [[  stage_in  ]],
//											  constant WorldUniforms  * worldUniforms [[  buffer(1) ]],
//											  constant Uniforms       * uniforms      [[  buffer(2) ]],
//											  texture2d<float> 			tex2D         [[ texture(0) ]],
//											  sampler          			sampler2D     [[ sampler(0) ]]) {
//
//	float2 sourceFragment;
//
//	// Frag X
//	if(frag.position.x < uniforms->squarePosition.x) {
//		sourceFragment.x = uniforms->squarePosition.x;
//	} else if(frag.position.x > uniforms->squarePosition.x + uniforms->squareSize.x) {
//		sourceFragment.x = uniforms->squarePosition.x + uniforms->squareSize.x;
//	} else {
//		sourceFragment.x = frag.position.x;
//	}
//
//	// Frag Y
//	if(frag.position.y < uniforms->squarePosition.y) {
//		sourceFragment.y = uniforms->squarePosition.y;
//	} else if(frag.position.y > uniforms->squarePosition.y + uniforms->squareSize.y) {
//		sourceFragment.y = uniforms->squarePosition.y + uniforms->squareSize.y;
//	} else {
//		sourceFragment.y = frag.position.y;
//	}
//
//	// Normalize coordinates
//	sourceFragment.x /= worldUniforms->resolution.x;
//	sourceFragment.y /= worldUniforms->resolution.y;
//
//	float4 color = tex2D.sample(sampler2D, sourceFragment);
//	return float4(color);
//}

#endif
