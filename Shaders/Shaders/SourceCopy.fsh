//
//  Shader.fsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#ifdef GL_ES
precision lowp float;
#endif

varying vec2 v_texture;

uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

uniform float u_alpha;
uniform float u_gamma;

// #############################################################################

void main()
    {
	vec4 S = texture2D(u_texture0, v_texture);
	vec4 D = texture2D(u_texture1, v_texture);

	D.a *= u_alpha;

	gl_FragColor = S * (1.0 - D.a) + D * D.a;
    }
