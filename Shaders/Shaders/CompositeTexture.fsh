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

// #############################################################################

varying vec2 v_texture0;

uniform sampler2D u_texture0; //@ name:texture0
uniform sampler2D u_texture1; //@ name:texture1

uniform int u_blendMode; //@ name:blendMode
uniform float u_alpha; //@ name:alpha
uniform float u_gamma; //@ name:gamma
uniform vec4 u_color; //@ name:color, usage:color

// #############################################################################

vec3 gamma_correct(vec3 C)
	{
	return pow(C, vec3(u_gamma)); // desiredGamma / currentGamma
	}

vec4 premultiply(vec4 v)
	{
	return vec4(v.r * v.a, v.g * v.a, v.b * v.a, v.a);
	}

// #############################################################################

void main()
    {
	vec4 S = texture2D(u_texture0, v_texture0);
	vec4 D = texture2D(u_texture1, v_texture0) + u_color;
	vec4 Sp = premultiply(S);
	vec4 Dp = premultiply(D);

	D.a *= u_alpha;

	vec4 OUT = S;

	// The big uber IF statement is inefficient. Better to use multiple shaders for this...

	if (u_blendMode == kCGBlendModeNormal)
		{
		OUT = S * (1.0 - D.a) + D * D.a;
		}
	else if (u_blendMode == kCGBlendModeMultiply)
		{
		OUT.rgb = Sp.rgb * Dp.rgb;
		}
	else if (u_blendMode == kCGBlendModeScreen)
		{
		OUT.r = 1.0 - ((1.0 - Sp.r) * (1.0 - Dp.r));
		OUT.g = 1.0 - ((1.0 - Sp.g) * (1.0 - Dp.g));
		OUT.b = 1.0 - ((1.0 - Sp.b) * (1.0 - Dp.b));
		}
	else if (u_blendMode == kCGBlendModeOverlay)
		{
		// AGED
		D *= u_alpha;
		OUT.rgb = BlendOverlay(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeDarken)
		{
		// AGED
		OUT = BlendDarken(S, D);
		}
	else if (u_blendMode == kCGBlendModeLighten)
		{
		// AGED
		OUT = BlendLighten(S, D);
		}
	else if (u_blendMode == kCGBlendModeColorDodge)
		{
		OUT.rgb = BlendColorDodge(Sp.rgb, Dp.rgb);
		}
	else if (u_blendMode == kCGBlendModeColorBurn)
		{
		// AGED
		OUT.rgb = BlendColorBurn(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeSoftLight)
		{
		// AGED
		OUT.rgb = BlendSoftLight(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeHardLight)
		{
		OUT.rgb = BlendHardLight(Sp.rgb, Dp.rgb);
		}
	else if (u_blendMode == kCGBlendModeDifference)
		{
		OUT.rgb = BlendDifference(Sp.rgb, Dp.rgb);
		}
	else if (u_blendMode == kCGBlendModeExclusion)
		{
		OUT.rgb = BlendExclusion(Sp.rgb, Dp.rgb);
		}
	else if (u_blendMode == kCGBlendModeHue)
		{
		OUT.rgb = BlendHue(Dp.rgb, Sp.rgb);
		}
	else if (u_blendMode == kCGBlendModeSaturation)
		{
		OUT.rgb = BlendSaturation(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeColor)
		{
		OUT.rgb = BlendColor(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeLuminosity)
		{
		OUT.rgb = BlendLuminosity(S.rgb, D.rgb);
		}
	else if (u_blendMode == kCGBlendModeClear)
		{
		OUT = vec4(1.0, 1.0, 1.0, 0.0);
		}
	else if (u_blendMode == kCGBlendModeCopy)
		{
		OUT = D;
		}
	else if (u_blendMode == kCGBlendModeSourceIn)
		{
		OUT = D * S.a * D.a;
		}
	else if (u_blendMode == kCGBlendModeSourceOut)
		{
		OUT = D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModeSourceAtop)
		{
		OUT = Dp * Sp.a + Sp * (1.0 - Dp.a);
		}
	else if (u_blendMode == kCGBlendModeDestinationOver)
		{
		OUT = Dp * (1.0 - Sp.a) + Sp;
		}
	else if (u_blendMode == kCGBlendModeDestinationIn)
		{
		OUT = Sp * Dp.a;
		}
	else if (u_blendMode == kCGBlendModeDestinationOut)
		{
		OUT = Sp * (1.0 - Dp.a);
		}
	else if (u_blendMode == kCGBlendModeDestinationAtop)
		{
		OUT = Dp * (1.0 - Sp.a) + Sp * Dp.a;
		}
	else if (u_blendMode == kCGBlendModeXOR)
		{
		OUT = Sp * (1.0 - Dp.a) + Dp * (1.0 - Sp.a);
		}
	else if (u_blendMode == kCGBlendModePlusDarker)
		{
		OUT.r = max(0.0, (1.0 - Dp.r) + (1.0 - Sp.r));
		OUT.g = max(0.0, (1.0 - Dp.g) + (1.0 - Sp.g));
		OUT.b = max(0.0, (1.0 - Dp.b) + (1.0 - Sp.b));

//		OUT.rgb = max(0.0, (1.0 - Dp) + (1.0 - Sp))
		}
	else if (u_blendMode == kCGBlendModePlusLighter)
		{
		OUT.r = min(1.0, Dp.r + Sp.r);
		OUT.g = min(1.0, Dp.g + Sp.g);
		OUT.b = min(1.0, Dp.b + Sp.b);
		OUT.a = min(1.0, Dp.a + Sp.a);
		}
	else
		{
		OUT = vec4(1.0, 0.0, 0.0, 1.0);
		}

	OUT = S * (1.0 - OUT.a) + OUT * OUT.a;

	gl_FragColor = OUT;
    }
