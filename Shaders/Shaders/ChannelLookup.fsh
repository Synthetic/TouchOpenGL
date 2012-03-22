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
uniform sampler1D u_redLUT; //@ name:redLUT
uniform sampler1D u_greenLUT; //@ name:greenLUT
uniform sampler1D u_blueLUT; //@ name:blueLUT

void main()
    {
	vec4 theSourceColor = texture2D(u_texture0, v_texture0);

//	gl_FragColor = theSourceColor;

	gl_FragColor.r = texture1D(u_redLUT, theSourceColor.r).r;
	gl_FragColor.g = texture1D(u_greenLUT, theSourceColor.g).g;
	gl_FragColor.b = texture1D(u_blueLUT, theSourceColor.b).b;
	gl_FragColor.a = theSourceColor.a;
    }
