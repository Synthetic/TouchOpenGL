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

// #############################################################################

#define float4 vec4
#define float3 vec3
#define lerp mix

/*
** Photoshop & misc math
** Blending modes, RGB/HSL/Contrast/Desaturate
**
** Romain Dura | Romz
** Blog: http://blog.mouaif.org
** Post: http://blog.mouaif.org/?p=94
*/


/*
** Desaturation
*/

float4 Desaturate(float3 color, float Desaturation)
{
	float3 grayXfer = float3(0.3, 0.59, 0.11);
	float grayf = dot(grayXfer, color);
	float3 gray = float3(grayf, grayf, grayf);
	return float4(lerp(color, gray, Desaturation), 1.0);
}


/*
** Hue, saturation, luminance
*/

float3 RGBToHSL(float3 color)
{
	float3 hsl; // init to 0 to avoid warnings ? (and reverse if + remove first part)
	
	float fmin = min(min(color.r, color.g), color.b);    //Min. value of RGB
	float fmax = max(max(color.r, color.g), color.b);    //Max. value of RGB
	float delta = fmax - fmin;             //Delta RGB value

	hsl.z = (fmax + fmin) / 2.0; // Luminance

	if (delta == 0.0)		//This is a gray, no chroma...
	{
		hsl.x = 0.0;	// Hue
		hsl.y = 0.0;	// Saturation
	}
	else                                    //Chromatic data...
	{
		if (hsl.z < 0.5)
			hsl.y = delta / (fmax + fmin); // Saturation
		else
			hsl.y = delta / (2.0 - fmax - fmin); // Saturation
		
		float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
		float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
		float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;

		if (color.r == fmax )
			hsl.x = deltaB - deltaG; // Hue
		else if (color.g == fmax)
			hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
		else if (color.b == fmax)
			hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue

		if (hsl.x < 0.0)
			hsl.x += 1.0; // Hue
		else if (hsl.x > 1.0)
			hsl.x -= 1.0; // Hue
	}

	return hsl;
}

float HueToRGB(float f1, float f2, float hue)
{
	if (hue < 0.0)
		hue += 1.0;
	else if (hue > 1.0)
		hue -= 1.0;
	float res;
	if ((6.0 * hue) < 1.0)
		res = f1 + (f2 - f1) * 6.0 * hue;
	else if ((2.0 * hue) < 1.0)
		res = f2;
	else if ((3.0 * hue) < 2.0)
		res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
	else
		res = f1;
	return res;
}

float3 HSLToRGB(float3 hsl)
{
	float3 rgb;
	
	if (hsl.y == 0.0)
		rgb = float3(hsl.z, hsl.z, hsl.z); // Luminance
	else
	{
		float f2;
		
		if (hsl.z < 0.5)
			f2 = hsl.z * (1.0 + hsl.y);
		else
			f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
			
		float f1 = 2.0 * hsl.z - f2;
		
		rgb.r = HueToRGB(f1, f2, hsl.x + (1.0/3.0));
		rgb.g = HueToRGB(f1, f2, hsl.x);
		rgb.b= HueToRGB(f1, f2, hsl.x - (1.0/3.0));
	}
	
	return rgb;
}

/*
** Contrast, saturation, brightness
** Code of this function is from TGM's shader pack
** http://irrlicht.sourceforge.net/phpBB2/viewtopic.php?t=21057
*/

// For all settings: 1.0 = 100% 0.5=50% 1.5 = 150%
float3 ContrastSaturationBrightness(float3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const float3 LumCoeff = float3(0.2125, 0.7154, 0.0721);
	
	float3 AvgLumin = float3(AvgLumR, AvgLumG, AvgLumB);
	float3 brtColor = color * brt;
	float intensityf = dot(brtColor, LumCoeff);
	float3 intensity = float3(intensityf, intensityf, intensityf);
	float3 satColor = lerp(intensity, brtColor, sat);
	float3 conColor = lerp(AvgLumin, satColor, con);
	return conColor;
}

/*
** Float blending modes
** Adapted from here: http://www.nathanm.com/photoshop-blending-math/
** But I modified the HardMix (wrong condition), Overlay, SoftLight, ColorDodge, ColorBurn, VividLight, PinLight (inverted layers) ones to have correct results
*/

#define BlendLinearDodgef 			BlendAddf
#define BlendLinearBurnf 			BlendSubstractf
#define BlendAddf(base, blend) 		min(base + blend, 1.0)
#define BlendSubstractf(base, blend) 	max(base + blend - 1.0, 0.0)
#define BlendLightenf(base, blend) 		max(blend, base)
#define BlendDarkenf(base, blend) 		min(blend, base)
#define BlendLinearLightf(base, blend) 	(blend < 0.5 ? BlendLinearBurnf(base, (2.0 * blend)) : BlendLinearDodgef(base, (2.0 * (blend - 0.5))))
#define BlendScreenf(base, blend) 		(1.0 - ((1.0 - base) * (1.0 - blend)))
#define BlendOverlayf(base, blend) 	(base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define BlendSoftLightf(base, blend) 	((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define BlendColorDodgef(base, blend) 	((blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0))
#define BlendColorBurnf(base, blend) 	((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
#define BlendVividLightf(base, blend) 	((blend < 0.5) ? BlendColorBurnf(base, (2.0 * blend)) : BlendColorDodgef(base, (2.0 * (blend - 0.5))))
#define BlendPinLightf(base, blend) 	((blend < 0.5) ? BlendDarkenf(base, (2.0 * blend)) : BlendLightenf(base, (2.0 *(blend - 0.5))))
#define BlendHardMixf(base, blend) 	((BlendVividLightf(base, blend) < 0.5) ? 0.0 : 1.0)
#define BlendReflectf(base, blend) 		((blend == 1.0) ? blend : min(base * base / (1.0 - blend), 1.0))



/*
** Vector3 blending modes
*/

// Component wise blending
#define Blend(base, blend, funcf) 		float3(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b))

#define BlendNormal(base, blend) 		(base)
#define BlendLighten				BlendLightenf
#define BlendDarken				BlendDarkenf
#define BlendMultiply(base, blend) 		(base * blend)
#define BlendAverage(base, blend) 		((base + blend) / 2.0)
#define BlendAdd(base, blend) 		min(base + blend, float3(1.0, 1.0, 1.0))
#define BlendSubstract(base, blend) 	max(base + blend - float3(1.0, 1.0, 1.0), float3(0.0, 0.0, 0.0))
#define BlendDifference(base, blend) 	abs(base - blend)
#define BlendNegation(base, blend) 	(float3(1.0, 1.0, 1.0) - abs(float3(1.0, 1.0, 1.0) - base - blend))
#define BlendExclusion(base, blend) 	(base + blend - 2.0 * base * blend)
#define BlendScreen(base, blend) 		Blend(base, blend, BlendScreenf)
#define BlendOverlay(base, blend) 		Blend(base, blend, BlendOverlayf)
#define BlendSoftLight(base, blend) 	Blend(base, blend, BlendSoftLightf)
#define BlendHardLight(base, blend) 	BlendOverlay(blend, base)
#define BlendColorDodge(base, blend) 	Blend(base, blend, BlendColorDodgef)
#define BlendColorBurn(base, blend) 	Blend(base, blend, BlendColorBurnf)
#define BlendLinearDodge			BlendAdd
#define BlendLinearBurn			BlendSubstract

// Linear Light is another contrast-increasing mode
// If the blend color is darker than midgray, Linear Light darkens the image by decreasing the brightness. If the blend color is lighter than midgray, the result is a brighter image due to increased brightness.
#define BlendLinearLight(base, blend) 	Blend(base, blend, BlendLinearLightf)

#define BlendVividLight(base, blend) 	Blend(base, blend, BlendVividLightf)
#define BlendPinLight(base, blend) 		Blend(base, blend, BlendPinLightf)
#define BlendHardMix(base, blend) 		Blend(base, blend, BlendHardMixf)
#define BlendReflect(base, blend) 		Blend(base, blend, BlendReflectf)
#define BlendGlow(base, blend) 		BlendReflect(blend, base)
#define BlendPhoenix(base, blend) 		(min(base, blend) - max(base, blend) + float3(1.0, 1.0, 1.0))
#define BlendOpacity(base, blend, F, O) 	(F(base, blend) * O + blend * (1.0 - O))

// Hue Blend mode creates the result color by combining the luminance and saturation of the base color with the hue of the blend color.
float3 BlendHue(float3 base, float3 blend)
{
	float3 baseHSL = RGBToHSL(base);
	return HSLToRGB(float3(RGBToHSL(blend).r, baseHSL.g, baseHSL.b));
}

// Saturation Blend mode creates the result color by combining the luminance and hue of the base color with the saturation of the blend color.
float3 BlendSaturation(float3 base, float3 blend)
{
	float3 baseHSL = RGBToHSL(base);
	return HSLToRGB(float3(baseHSL.r, RGBToHSL(blend).g, baseHSL.b));
}

// Color Mode keeps the brightness of the base color and applies both the hue and saturation of the blend color.
float3 BlendColor(float3 base, float3 blend)
{
	float3 blendHSL = RGBToHSL(blend);
	return HSLToRGB(float3(blendHSL.r, blendHSL.g, RGBToHSL(base).b));
}

// Luminosity Blend mode creates the result color by combining the hue and saturation of the base color with the luminance of the blend color.
float3 BlendLuminosity(float3 base, float3 blend)
{
	float3 baseHSL = RGBToHSL(base);
	return HSLToRGB(float3(baseHSL.r, baseHSL.g, RGBToHSL(blend).b));
}

// #############################################################################

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
		gl_FragColor.rgb = BlendOverlay(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeDarken)
		{
		gl_FragColor = BlendDarken(S, D);
		}
	else if (u_blendMode == kCGBlendModeLighten)
		{
		gl_FragColor = BlendLighten(S, D);
		}
	else if (u_blendMode == kCGBlendModeColorDodge)
		{
		gl_FragColor.rgb = BlendColorDodge(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeColorBurn)
		{
		gl_FragColor.rgb = BlendColorBurn(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeSoftLight)
		{
		gl_FragColor.rgb = BlendSoftLight(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeHardLight)
		{
		gl_FragColor.rgb = BlendHardLight(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeDifference)
		{
		gl_FragColor.rgb = BlendDifference(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeExclusion)
		{
		gl_FragColor.rgb = BlendExclusion(S.rgb, D.rgb);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeHue)
		{
		// TODO
		gl_FragColor.rgb = BlendHue(S.rgb, D.rbg);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeSaturation)
		{
		gl_FragColor.rgb = BlendSaturation(S.rgb, D.rbg);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeColor)
		{
		gl_FragColor.rgb = BlendColor(S.rgb, D.rbg);
		gl_FragColor.a = 1.0;
		}
	else if (u_blendMode == kCGBlendModeLuminosity)
		{
		gl_FragColor.rgb = BlendLuminosity(S.rgb, D.rbg);
		gl_FragColor.a = 1.0;
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
