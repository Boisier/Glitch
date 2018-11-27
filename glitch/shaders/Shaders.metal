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
									 texture2d<float> tex2D         [[ texture(0) ]],
									 sampler          sampler2D     [[ sampler(0) ]])
{
	return tex2D.sample(sampler2D, frag.uv);
}

#endif
