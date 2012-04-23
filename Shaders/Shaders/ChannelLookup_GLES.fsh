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

varying vec2 v_texture0;

uniform sampler2D u_texture0; //@ name:texture0
uniform sampler2D u_redLUT; //@ name:redLUT
uniform sampler2D u_greenLUT; //@ name:greenLUT
uniform sampler2D u_blueLUT; //@ name:blueLUT

void main()
    {
	vec4 theSourceColor = texture2D(u_texture0, v_texture0);

//	gl_FragColor = theSourceColor;

	gl_FragColor.r = texture2D(u_redLUT, vec2(theSourceColor.r, 0.5)).r;
	gl_FragColor.g = texture2D(u_greenLUT, vec2(theSourceColor.g, 0.5)).g;
	gl_FragColor.b = texture2D(u_blueLUT, vec2(theSourceColor.b, 0.5)).b;
	gl_FragColor.a = theSourceColor.a;
    }
