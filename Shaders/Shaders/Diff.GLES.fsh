//
//  Shader.fsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texture0;

uniform sampler2D u_texture0; //@ name:texture0
uniform sampler2D u_texture1; //@ name:texture1

void main()
    {
	vec4 S = texture2D(u_texture0, v_texture0);
	vec4 D = texture2D(u_texture1, v_texture0);
	
	S *= S.a;
	D *= D.a;

	float SL = (0.2126 * S.r) + (0.7152 * S.g) + (0.0722 * S.b);
	float DL = (0.2126 * D.r) + (0.7152 * D.g) + (0.0722 * D.b);

	float diff = 1.0 - abs(SL - DL);

    gl_FragColor = vec4(diff, diff, diff, 1.0);
    }
