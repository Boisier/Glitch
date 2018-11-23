//
//  structures.metal
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef STRUCTURES
#define STRUCTURES

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

/// Vertex input structure
typedef struct {
	float3 position;
	float2 uv;
} VertexIn;

/// Vertex convenient format
typedef struct {
	float4 position [[position]];
	float2 uv;
} Vertex;

/// World unfiforms
typedef struct {
	float2 resolution;
	float4x4 projectionMatrix;
} WorldUniforms;

// //////////////////////////
// Glitch effects structures


typedef struct {
	int effectsCount;
	int effectsIdentifiers;
	int effectsParametersCount;
	float4 parametersValue;
} Uniforms;

typedef struct {
	float4 value;
} ShaderArray;

#endif
