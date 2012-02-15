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
#define kCGBlendModeXOR 26
#define kCGBlendModePlusDarker 27
#define kCGBlendModePlusLighter 28

varying vec2 v_texture;

uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

uniform int u_blendMode;

vec4 premultiply(vec4 v)
	{
	return vec4(v.r * v.a, v.g * v.a, v.b * v.a, 1.0);
	}

// #############################################################################

vec4 RGBToHSV(vec4 RGB)
	{
	float Max;
	float Min;
	float Chroma;
	vec4 HSV; // xyzw -> hsva
 
	Min = min(min(RGB.r, RGB.g), RGB.b);
	Max = max(max(RGB.r, RGB.g), RGB.b);
	Chroma = Max - Min;
 
	//If Chroma is 0, then S is 0 by definition, and H is undefined but 0 by convention.
	if (Chroma != 0.0)
		{
		if (RGB.r == Max)
			{
			HSV.x = (RGB.g - RGB.b) / Chroma;
			if(HSV.x < 0.0)
				{
				HSV.x += 6.0;
				}
			}
		else if(RGB.g == Max)
			{
			HSV.x = ((RGB.b - RGB.r) / Chroma) + 2.0;
			}
		else //RGB.b == Max
			{
			HSV.x = ((RGB.r - RGB.g) / Chroma) + 4.0;
			}
 
		HSV.x *= 60.0;
		HSV.y = Chroma / Max;
	}
	HSV.z = Max;
	HSV.w = RGB.a;
	return HSV ;
	}
 
// #############################################################################

void main()
    {
	vec4 S = texture2D(u_texture1, v_texture);
	vec4 D = texture2D(u_texture0, v_texture);
	
//	S = premultiply(S);
//	D = premultiply(D);

	gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);

	// The big uber IF statement is inefficient. Better to use multiple shaders for this...
	
	if (u_blendMode == kCGBlendModeNormal)
		{
		gl_FragColor = D * (1.0 - S.a) + S * S.a;
		}
	else if (u_blendMode == kCGBlendModeMultiply)
		{
		gl_FragColor = D * S;
		}
	else if (u_blendMode == kCGBlendModeScreen)
		{
		gl_FragColor.r = 1.0 - ((1.0 - S.r) * (1.0 - D.r));
		gl_FragColor.g = 1.0 - ((1.0 - S.g) * (1.0 - D.g));
		gl_FragColor.b = 1.0 - ((1.0 - S.b) * (1.0 - D.b));
		gl_FragColor.a = 1.0 - ((1.0 - S.a) * (1.0 - D.a));
		}
	else if (u_blendMode == kCGBlendModeOverlay)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeDarken)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeLighten)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeColorDodge)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeColorBurn)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeSoftLight)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeHardLight)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeDifference)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeExclusion)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeHue)
		{
		// TODO
		vec4 S_HSV = RGBToHSV(S);
		vec4 D_HSV = RGBToHSV(D);
		
		
		
		
		}
	else if (u_blendMode == kCGBlendModeSaturation)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeColor)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeLuminosity)
		{
		// TODO
		}
	else if (u_blendMode == kCGBlendModeClear)
		{
		gl_FragColor = vec4(1.0, 1.0, 1.0, 0.0);
		}
	else if (u_blendMode == kCGBlendModeCopy)
		{
		gl_FragColor = S;
		}
	else if (u_blendMode == kCGBlendModeSourceIn)
		{
		gl_FragColor = S * D.a;
		}
	else if (u_blendMode == kCGBlendModeSourceOut)
		{
		gl_FragColor = S * (1.0 - D.a);
		}
	else if (u_blendMode == kCGBlendModeSourceAtop)
		{
		gl_FragColor = S * D.a + D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModeDestinationOver)
		{
		gl_FragColor = S * (1.0 - D.a) + D;
		}
	else if (u_blendMode == kCGBlendModeDestinationIn)
		{
		gl_FragColor = D * S.a;
		}
	else if (u_blendMode == kCGBlendModeDestinationOut)
		{
		gl_FragColor = D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModeDestinationAtop)
		{
		gl_FragColor = S * (1.0 - D.a) + D * S.a;
		}
	else if (u_blendMode == kCGBlendModeXOR)
		{
		gl_FragColor = S * (1.0 - D.a) + D * (1.0 - S.a);
		}
	else if (u_blendMode == kCGBlendModePlusDarker)
		{
		gl_FragColor.r = max(0.0, (1.0 - D.r) + (1.0 - S.r));
		gl_FragColor.g = max(0.0, (1.0 - D.g) + (1.0 - S.g));
		gl_FragColor.b = max(0.0, (1.0 - D.b) + (1.0 - S.b));
		gl_FragColor.a = max(0.0, (1.0 - D.a) + (1.0 - S.a));
		}
	else if (u_blendMode == kCGBlendModePlusLighter)
		{
		gl_FragColor.r = min(1.0, S.r + D.r);
		gl_FragColor.g = min(1.0, S.g + D.g);
		gl_FragColor.b = min(1.0, S.b + D.b);
		gl_FragColor.a = min(1.0, S.a + D.a);
		}
    }
