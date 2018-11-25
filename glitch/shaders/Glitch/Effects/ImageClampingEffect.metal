//
//  ImageClampingEffect.metal
//  glitch
//
//  Created by Valentin Dufois on 23/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "ImageClampingEffect.hpp"

void ImageClampingEffect::executeRenderPass(const int renderPass) {
	uint2 sourcePixel;

	float squareSize = _uniforms[0].parametersValues.x;
	float2 squarePosition = _uniforms[1].parametersValues.xy;

	// Frag X
	if(_position.x < squarePosition.x) {
		sourcePixel.x = squarePosition.x;
	} else if(_position.x > squarePosition.x + squareSize) {
		sourcePixel.x = squarePosition.x + squareSize;
	} else {
		sourcePixel.x = _position.x;
	}

	// Frag Y
	if(_position.y < squarePosition.y) {
		sourcePixel.y = squarePosition.y;
	} else if(_position.y > squarePosition.y + squareSize) {
		sourcePixel.y = squarePosition.y + squareSize;
	} else {
		sourcePixel.y = _position.y;
	}

	_bridgeTexture.write(_bridgeTexture.read(sourcePixel), _position);
}
