//
//  VerticalGlitchEffect.metal
//  glitch
//
//  Created by Valentin Dufois on 23/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "VerticalGlitchEffect.hpp"

void VerticalGlitchEffect::executeRenderPass(const int renderPass) {
	if(renderPass != 0) return;

	int lineY = _uniforms[0].parametersValues.x;

	_bridgeTexture.write(_bridgeTexture.read(uint2(_position.x, lineY)), _position);
}
