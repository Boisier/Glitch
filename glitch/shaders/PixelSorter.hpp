//
//  PixelSorter.h
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef PixelSorter_h
#define PixelSorter_h

#define SCALINGFACTOR 100.0

#include <metal_stdlib>
#include <simd/simd.h>

#import "structures.h"
#import "utils.hpp"

using namespace metal;

class PixelSorter {
public: 
	PixelSorter(constant Uniforms 		 * uniforms,
				int			   cursorPosition,
				texture2d<float> texture,
				sampler          sampler2D,
				constant WorldUniforms  * worldUniforms,
				device float4 * shaderArray):
	_uniforms(uniforms), _cursorPosition(cursorPosition), _texture(texture), _sampler(sampler2D), _worldUniforms(worldUniforms), _array(shaderArray) {}

	float4 forFragment(Vertex frag, float4 color);

private:

	// ////////
	// Methods

	float2 findVerticalBound(const float2 startPosition, const float increment);
	bool sectionChangeInInterval(float2 startPosition, float dist, const float increment);

	int getSection(const float2 position);

	inline float4 getColor(const float2 position) { return _texture.sample(_sampler, position / SCALINGFACTOR); }

	float2 getNLuminousFragInSection(const int n, float2 topBound, float2 bottomBound, float increment);

	// ///////////
	// Input properties
	constant Uniforms * _uniforms;
	int _cursorPosition;
	constant WorldUniforms *_worldUniforms;

	texture2d<float> _texture;
	sampler _sampler;

	device float4 *_array;

	// ///////////////////
	// Runtime properties

	float _upperThreshold = 1.0;
	float _lowerThreshold = 0.0;

	float _smoothness = 1.0;

	// ////////////
	// Bounds

	float2 _topBound;
	float2 _bottomBound;
};

#endif /* PixelSorter_h */
