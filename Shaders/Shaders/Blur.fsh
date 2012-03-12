//
//  Shader.fsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#version 120

#ifdef GL_ES
precision mediump float;
#else
#extension GL_EXT_gpu_shader4 : require
#endif

varying vec2 v_texture0;
uniform sampler2D u_texture0; //@ name:texture0, type:texture
uniform bool u_vertical; //@ name:vertical, type:bool, default:NO

void main(void)
	{
	ivec2 theTextureSize = textureSize2D(u_texture0, 0);
	vec2 theOffset = u_vertical ? vec2(0.0, 1.0 / theTextureSize.y) : vec2(1.0 / theTextureSize.x, 0.0);

	// Mostly from: http://www.gamerendering.com/2008/10/11/gaussian-blur-filter-shader/
	// take nine samples, with the distance kBlurSize between them
	vec4 sum = texture2D(u_texture0, v_texture0 - 0.0 * theOffset) * 0.16;
	sum += texture2D(u_texture0, v_texture0 - 4.0 * theOffset) * 0.05;
	sum += texture2D(u_texture0, v_texture0 - 3.0 * theOffset) * 0.09;
	sum += texture2D(u_texture0, v_texture0 - 2.0 * theOffset) * 0.12;
	sum += texture2D(u_texture0, v_texture0 - 1.0 * theOffset) * 0.15;
	sum += texture2D(u_texture0, v_texture0 + 1.0 * theOffset) * 0.15;
	sum += texture2D(u_texture0, v_texture0 + 2.0 * theOffset) * 0.12;
	sum += texture2D(u_texture0, v_texture0 + 3.0 * theOffset) * 0.09;
	sum += texture2D(u_texture0, v_texture0 + 4.0 * theOffset) * 0.05;

	// Without this multiplier the output will slowly converge towards 0.0
	gl_FragColor = sum * 1.02040816326531;
	}
