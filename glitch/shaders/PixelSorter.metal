//
//  pixelSortingFragment.metal
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "PixelSorter.hpp"


using namespace metal;


// Every UV coordinates will be scaled times 100
float4 PixelSorter::forFragment(Vertex frag, float4 currentColor)
{
	// Get upper and lower bounds
	_upperThreshold = _uniforms[_cursorPosition].parametersValue.x / 255.0;
	_lowerThreshold = _uniforms[_cursorPosition].parametersValue.y / 255.0;

	_smoothness = _uniforms[_cursorPosition + 1].parametersValue.x / 255.0;

	int renderStep = int(_uniforms[_cursorPosition + 2].parametersValue.x);

	float2 fragUV = frag.uv * SCALINGFACTOR;

	if((int(fragUV.y) % 2) != 0 || (int(fragUV.x) % 2) != 0)
		return float4(0, 0, 0, 1);


	if(_smoothness == 0)
		return getColor(fragUV);

	if(renderStep == 0) {
		return luminance(getColor(fragUV));
	}

	// Get the increment between frags
	float increment = (SCALINGFACTOR / _worldUniforms->resolution.y) * _smoothness;

	// Determine this section bounds
	_bottomBound = findVerticalBound(fragUV, increment);
	_topBound = findVerticalBound(fragUV, -increment);

	if(renderStep == 1) {
		if(int(_topBound.y) == int(fragUV.y))
			return float4(1, 0, 0, 1);

		if(int(_bottomBound.y) == int(fragUV.y))
			return float4(0, 1, 0, 1);

		return float4(0);
	}

	// Get the number of frags in the section
	//float sectionFragsCount = (_bottomBound.y - _topBound.y) / increment;

	// Get our current fragment position in the section
	float currentFragPosition = (fragUV.y - _topBound.y) / increment;

	if(renderStep == 2) {
		return getColor(_topBound);
	}

	if(renderStep == 3) {
		return float4(currentFragPosition/SCALINGFACTOR, currentFragPosition/SCALINGFACTOR, currentFragPosition/SCALINGFACTOR, 1);
	}

	return getColor(getNLuminousFragInSection(currentFragPosition, _topBound, _bottomBound, increment*2));

}

float2 PixelSorter::getNLuminousFragInSection(const int n, float2 topBound, float2 bottomBound, float increment) {
	float2 position;
	float maxLuminance = 1.1;
	float2 maxLuminancePosition;
	float currentLuminance;
	float2 currentLuminancePosition;
	float luma;

	for(int i = 0; i < n; ++i)
	{
		position = topBound;
		currentLuminance = 0.0;

		while (position.y < bottomBound.y)
		{
			luma = luminance(getColor(position));

			if(luma > currentLuminance && luma < maxLuminance) {
				currentLuminance = luma;
				currentLuminancePosition = position;
			}

			position.y += increment;
		}

		maxLuminance = currentLuminance;
		maxLuminancePosition = currentLuminancePosition;
	}

	return maxLuminancePosition;
}

float2 PixelSorter::findVerticalBound(const float2 startPosition, const float increment) {
	int startSection = getSection(startPosition);
	int currentSection = startSection;

	float2 position = startPosition;

	while(startSection == currentSection && position.y > 0.0 && position.y < SCALINGFACTOR)
	{
		position.y += increment;
		currentSection = getSection(position);

		/*if(startSection != currentSection) {
			if(sectionChangeInInterval(position, increment * _smoothness, increment)) {
				currentSection = startSection;
			}
		}*/
	}

	return position;
}

bool PixelSorter::sectionChangeInInterval(float2 startPosition, float dist, const float increment) {
	int startSection = getSection(startPosition);
	int currentSection = startSection;

	float2 position = startPosition;
	position.y += increment;

	do {
		currentSection = getSection(position);
		position.y += increment;
	} while(startSection == currentSection && abs(position.y - startPosition.y) < dist);

	if(startSection != currentSection) {
		startPosition = position;
		return true;
	}

	return false;
}

int PixelSorter::getSection(const float2 position) {
	float luma = luminance(getColor(position));
	return luma > _lowerThreshold && luma < _upperThreshold ? 1 : 0;
}
