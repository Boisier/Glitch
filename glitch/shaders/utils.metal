//
//  utils.metal
//  glitch
//
//  Created by Valentin Dufois on 21/11/2018.
//  Copyright © 2018 Valentin Dufois. All rights reserved.
//

#include "utils.hpp"

using namespace metal;

float luminance(float4 color)
{
	return ((color.r * 0.3) + (color.g * 0.6) + (color.b * 0.1) ) * color.a;
}

void shellSort(device ShaderArray * frags, int size) {
	int inc = size / 2;
	while (inc > 0)
	{
		for (int i = inc; i < size; ++i)
		{
			float4 tmp = frags[i].value;
			int j = i;
			while (j >= inc && luminance(frags[j - inc].value) > luminance(tmp))
			{
				frags[j] = frags[j - inc];
				j -= inc;
			}
			frags[j].value = tmp;
		}
		inc = int(inc / 2.2 + 0.5);
	}
}
