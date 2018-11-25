//
//  SmearEffect.metal
//  glitch
//
//  Created by Valentin Dufois on 24/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "SmearEffect.hpp"

void SmearEffect::executeRenderPass(const int renderPass) {

	switch (renderPass) {
		case 0: passA(); break;
		case 1: passB(); break;
		default:
			return;
	}
}

void SmearEffect::passA() {
	float PI = 3.1415926535897932384626433832795;

	float4 inPixel = _bridgeTexture.read(_position);


	float angle = inPixel.b;
	float angleRad = 2*PI*angle;

	float2 factor = float2(cos(angleRad), sin(angleRad)) * _uniforms[0].parametersValues.x;
	float2 displacement = (inPixel.rg - 0.5) * factor;

	uint2 outPosition = _position + uint2(displacement);

	_bufferTextureA.write(_bridgeTexture.read(outPosition), _position);
}


void SmearEffect::passB() {
	_bridgeTexture.write(_bufferTextureA.read(_position), _position);
}
