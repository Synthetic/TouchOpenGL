//
//  Shader.fsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#ifdef GL_ES
precision highp float;
#endif

#include "PhotoshopMathFP.hlsl"

#define kCGBlendModeNormal 0
#define kCGBlendModeMultiply 1
#define kCGBlendModeScreen 2
#define kCGBlendModeOverlay 3
#define kCGBlendModeDarken 4
#define kCGBlendModeLighten 5
#define kCGBlendModeColorDodge 6
#define kCGBlendModeColorBurn 7
#define kCGBlendModeSoftLight 8
#define kCGBlendModeHardLight 9
#define kCGBlendModeDifference 10
#define kCGBlendModeExclusion 11
#define kCGBlendModeHue 12
#define kCGBlendModeSaturation 13
#define kCGBlendModeColor 14
#define kCGBlendModeLuminosity 15
#define kCGBlendModeClear 16
#define kCGBlendModeCopy 17
#define kCGBlendModeSourceIn 18
#define kCGBlendModeSourceOut 19
#define kCGBlendModeSourceAtop 20
#define kCGBlendModeDestinationOver 21
#define kCGBlendModeDestinationIn 22
#define kCGBlendModeDestinationOut 23
#define kCGBlendModeDestinationAtop 24
#define kCGBlendModeXOR 25
#define kCGBlendModePlusDarker 26
#define kCGBlendModePlusLighter 27

varying vec2 v_texture;

uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

uniform int u_blendMode;
uniform float u_alpha;
uniform float u_gamma;
uniform vec4 u_color;

vec3 gamma_correct(vec3 C)
	{
	return pow(C, vec3(u_gamma)); // desiredGamma / currentGamma
	}

vec4 premultiply(vec4 v)
	{
	return vec4(v.r * v.a, v.g * v.a, v.b * v.a, 1.0);
	}
 
// #############################################################################

void main()
    {
	vec4 S = texture2D(u_texture0, v_texture);
	vec4 D = texture2D(u_texture1, v_texture) + u_color;

	D.a *= u_alpha;
	
	vec4 OUT;

	// The big uber IF statement is inefficient. Better to use multiple shaders for this...
	
	if (u_blendMode == kCGBlendModeNormal)
		{
		OUT = S * (1.0 - D.a) + D * D.a;
		}
	else if (u_blendMode == kCGBlendModeMultiply)
		{
		OUT = S * D;
		}
	else if (u_blendMode == kCGBlendModeScreen)
		{
		OUT.r = 1.0 - ((1.0 - S.r) * (1.0 - D.r));
		OUT.g = 1.0 - ((1.0 - S.g) * (1.0 - D.g));
		OUT.b = 1.0 - ((1.0 - S.b) * (1.0 - D.b));
		}
	else if (u_blendMode == kCGBlendModeOverlay)
		{
		D *= u_alpha;
		OUT.rgb = BlendOverlay(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeDarken)
		{
		OUT = BlendDarken(S, D);
		}
	else if (u_blendMode == kCGBlendModeLighten)
		{
		OUT = BlendLighten(S, D);
		}
	else if (u_blendMode == kCGBlendModeColorDodge)
		{
		OUT.rgb = BlendColorDodge(S.rgb, D.rgb);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeColorBurn)
		{
		OUT.rgb = BlendColorBurn(S.rgb, D.rgb);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeSoftLight)
		{
		OUT.rgb = BlendSoftLight(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeHardLight)
		{
		OUT.rgb = BlendHardLight(S.rgb, D.rgb);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeDifference)
		{
		OUT.rgb = BlendDifference(S.rgb, D.rgb);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeExclusion)
		{
		OUT.rgb = BlendExclusion(S.rgb, D.rgb);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeHue)
		{
		OUT.rgb = BlendHue(D.rgb, S.rbg);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeSaturation)
		{
		OUT.rgb = BlendSaturation(S.rgb, D.rbg);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeColor)
		{
		OUT.rgb = BlendColor(S.rgb, D.rbg);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeLuminosity)
		{
		OUT.rgb = BlendLuminosity(S.rgb, D.rbg);
		OUT.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeClear)
		{
		OUT = vec4(1.0, 1.0, 1.0, 0.0);
		}
	else if (u_blendMode == kCGBlendModeCopy)
		{
		OUT = S;
		}
	else if (u_blendMode == kCGBlendModeSourceIn)
		{
		OUT = D * S.a * D.a;
		}
	else if (u_blendMode == kCGBlendModeSourceOut)
		{
		OUT = S * (1.0 - D.a);
		}
	else if (u_blendMode == kCGBlendModeSourceAtop)
		{
		OUT = S * D.a + D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModeDestinationOver)
		{
		OUT = S * (1.0 - D.a) + D;
		}
	else if (u_blendMode == kCGBlendModeDestinationIn)
		{
		OUT = D * S.a;
		}
	else if (u_blendMode == kCGBlendModeDestinationOut)
		{
		OUT = D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModeDestinationAtop)
		{
		OUT = S * (1.0 - D.a) + D * S.a;
		}
	else if (u_blendMode == kCGBlendModeXOR)
		{
		OUT = S * (1.0 - D.a) + D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModePlusDarker)
		{
		OUT.r = max(0.0, (1.0 - D.r) + (1.0 - S.r));
		OUT.g = max(0.0, (1.0 - D.g) + (1.0 - S.g));
		OUT.b = max(0.0, (1.0 - D.b) + (1.0 - S.b));
		OUT.a = max(0.0, (1.0 - D.a) + (1.0 - S.a));
		}
	else if (u_blendMode == kCGBlendModePlusLighter)
		{
		OUT.r = min(1.0, S.r + D.r);
		OUT.g = min(1.0, S.g + D.g);
		OUT.b = min(1.0, S.b + D.b);
		OUT.a = min(1.0, S.a + D.a);
		}
	else
		{
		OUT = vec4(1.0, 0.0, 0.0, 1.0);
		}

	gl_FragColor = OUT;
    }
