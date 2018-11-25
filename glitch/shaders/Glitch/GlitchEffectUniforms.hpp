//
//  GlitchEffectUniforms.hpp
//  glitch
//
//  Created by Valentin Dufois on 23/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#ifndef GlitchEffectUniforms_h
#define GlitchEffectUniforms_h

typedef struct {
	// Current effect
	int currentEffect;

	// Current effect identifier
	int currentEffectIdentifier;

	// Total number of effects
	int effectsCount;

	// Current Pass for this effect
	int currentPass;

	// Number of pass in the effect
	int effectPassCount;

	// All the current effect parameters in order
	float4 parametersValues;
} GlitchEffectUniforms;

#endif /* GlitchEffectUniforms_h */
