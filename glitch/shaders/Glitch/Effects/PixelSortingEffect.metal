//
//  PixelSortingEffect.metal
//  glitch
//
//  Created by Valentin Dufois on 24/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "PixelSortingEffect.hpp"


void PixelSortingEffect::executeRenderPass(const int renderPass) {
	float PI = 3.1415926535897932384626433832795;

	_threshold = _uniforms[0].parametersValues.x;

	float angle = _uniforms[1].parametersValues.x;
	float angleRad = 2*PI*( angle / 360);

	_nextVector = float2(cos(angleRad), sin(angleRad));

	switch (renderPass) {
		case 0: passA(); break;
		case 1: passA(); break;
		case 2: passA(); break;
		default:
			return;
	}
}

/// PASS A
void PixelSortingEffect::passA() {

	// Prev pixel
	sortWithPrevPixel();

	// Next pixel
	sortWithNextPixel();
}

void PixelSortingEffect::sortWithPrevPixel() {
	float4 inPixel = _bridgeTexture.read(_position);
	float inPixelValue = pixelValue(inPixel);
	uint2 prevPosition = toUint2(float2(_position) - _nextVector);

	if(!positionIsInTexture(prevPosition))
		return;

	float4 prevPixel = _bridgeTexture.read(prevPosition);
	float prevPixelValue = pixelValue(prevPixel);

	if(abs(inPixelValue - prevPixelValue) >= _threshold)
		return;

	if(inPixelValue <= prevPixelValue)
		return;

	_bridgeTexture.write(prevPixel, _position);
	_bridgeTexture.write(inPixel, prevPosition);

	inPixel = prevPixel;
	inPixelValue = prevPixelValue;
}


void PixelSortingEffect::sortWithNextPixel() {
	float4 inPixel = _bridgeTexture.read(_position);
	float inPixelValue = pixelValue(inPixel);
	uint2 nextPosition = toUint2(float2(_position) + _nextVector);

	if(!positionIsInTexture(nextPosition))
		return;

	float4 nextPixel = _bridgeTexture.read(nextPosition);
	float nextPixelValue = pixelValue(nextPixel);

	if(abs(inPixelValue - nextPixelValue) >= _threshold)
		return;

	if(inPixelValue >= nextPixelValue)
		return;

	_bridgeTexture.write(nextPixel, _position);
	_bridgeTexture.write(inPixel, nextPosition);
}

float PixelSortingEffect::pixelValue(const float4 color) {
	// Luminance
	return ((color.r * 0.3) + (color.g * 0.6) + (color.b * 0.1) ) * color.a;

	// Sum
	// return (color.r + color.g + color.b) / 4.0 * color.a;
}


bool PixelSortingEffect::sameSection(const float4 colorA, const float4 colorB) {
	return abs(pixelValue(colorA) - pixelValue(colorB)) < _threshold;
}

bool PixelSortingEffect::positionIsInTexture(const uint2 position) {
	return position.x < uint(_textureDimensions->x) &&
		   position.y < uint(_textureDimensions->y);
}

uint2 PixelSortingEffect::toUint2(float2 position) {
	return uint2(floor(position));
}
