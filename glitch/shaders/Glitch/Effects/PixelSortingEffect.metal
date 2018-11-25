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
//		case 1: passB(); break;
//		case 2: passC(); break;
		default:
			return;
	}
}

/// PASS A : Get all related informations for this precise pixel and execute the sorting
void PixelSortingEffect::passA() {
	if(_position.x == 0 && _position.y == 0) {
		float4 storedVector = _bufferTextureC.read(_position);
		if(storedVector.x == _nextVector.x && storedVector.y == _nextVector.y && storedVector.w == 0) {
			return;
		}

		_bufferTextureC.write(float4(_nextVector, 0, 0), _position);
	}


	float4 inPixel = _bridgeTexture.read(_position);

	// Start by getting all needed informations about the current pixel
	float value = pixelValue(inPixel);

	float2 precisePosition = float2(_position);
	float2 prevPosition = precisePosition - _nextVector;
	float2 nextPosition = precisePosition + _nextVector;

	bool isSectionStart = (!sameSection(inPixel, _bridgeTexture.read(toUint2(prevPosition))) && sameSection(inPixel, _bridgeTexture.read(toUint2(nextPosition))) ) || !positionIsInTexture(prevPosition);
	bool isSectionEnd = (sameSection(inPixel, _bridgeTexture.read(toUint2(prevPosition))) && !sameSection(inPixel, _bridgeTexture.read(toUint2(nextPosition)))) || !positionIsInTexture(nextPosition);


	_bufferTextureA.write(float4(value, float(isSectionStart), float(isSectionEnd), 1), _position);
	_bufferTextureB.write(inPixel, _position);
}


void PixelSortingEffect::passB() {
	float2 precisePosition = float2(_position);
	float2 prevPosition = precisePosition - _nextVector;
	float2 nextPosition = precisePosition + _nextVector;

	float4 inPixel = _bufferTextureA.read(_position);
	float4 inPixelInfos = _bufferTextureB.read(_position);

	// If this is not a section start, compare with previous
	if(!inPixelInfos.y) {
		float4 prevPixelInfos = _bufferTextureA.read(toUint2(prevPosition));

		if(prevPixelInfos.x < inPixelInfos.x) {
			// Inverse current and previous pixel on bridge and inverse values (x) on buffer A
			float4 newInPixelInfos = inPixelInfos;
			newInPixelInfos.x = prevPixelInfos.x;

			_bufferTextureB.write(inPixel, toUint2(prevPosition));
			_bufferTextureA.write(newInPixelInfos, _position);

			float4 newprevPixelInfos = prevPixelInfos;
			newprevPixelInfos.x = inPixel.x;
			float4 prevPixel = _bufferTextureB.read(toUint2(prevPosition));

			_bufferTextureB.write(prevPixel, _position);
			_bufferTextureA.write(newprevPixelInfos, toUint2(prevPosition));

			inPixel = prevPixel;
			inPixelInfos = newInPixelInfos;
		}
	}

	// If this is not a section end, compare with previous
	if(!inPixelInfos.z) {
		float4 nextPixelInfos = _bufferTextureA.read(toUint2(nextPosition));

		if(nextPixelInfos.x > inPixelInfos.x) {
			// Inverse current and previous pixel on bridge and inverse values (x) on buffer A
			float4 newInPixelInfos = inPixelInfos;
			newInPixelInfos.x = nextPixelInfos.x;

			_bufferTextureB.write(inPixel, toUint2(nextPosition));
			_bufferTextureA.write(newInPixelInfos, _position);

			float4 newNextPixelInfos = nextPixelInfos;
			newNextPixelInfos.x = inPixel.x;
			float4 nextPixel = _bufferTextureB.read(toUint2(nextPosition));

			_bufferTextureB.write(nextPixel, _position);
			_bufferTextureA.write(newNextPixelInfos, toUint2(nextPosition));

			inPixel = nextPixel;
			inPixelInfos = newInPixelInfos;
		}
	}

}


void PixelSortingEffect::passC() {
	_bridgeTexture.write(_bufferTextureB.read(_position), _position);
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

uint2 PixelSortingEffect::nextPosition(const uint2 currentPosition) {
	return nextPosition(float2(currentPosition.x, currentPosition.y));
}

uint2 PixelSortingEffect::nextPosition(float2 currentPosition) {
	float2 position = currentPosition + _nextVector;
	return uint2(position.x, position.y);
}


uint2 PixelSortingEffect::prevPosition(const uint2 currentPosition) {
	return prevPosition(float2(currentPosition.x, currentPosition.y));
}

uint2 PixelSortingEffect::prevPosition(float2 currentPosition) {
	float2 position = currentPosition - _nextVector;
	return uint2(position.x, position.y);
}

bool PixelSortingEffect::positionIsInTexture(const float2 precisePosition) {
	return precisePosition.x >= 0 &&
		   precisePosition.x < _textureDimensions->x &&
		   precisePosition.y >= 0 &&
		   precisePosition.y < _textureDimensions->y;
}

uint2 PixelSortingEffect::toUint2(float2 position) {
	return uint2(floor(position));
}
