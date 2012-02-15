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

varying vec2 v_texture;

uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

vec4 premultiply(vec4 v)
	{
	vec4 r = vec4(v.r * v.a, v.g * v.a, v.b * v.a, 1.0);
	return r;
	}

void main()
    {
	vec4 C1 = texture2D(u_texture0, v_texture);
	vec4 C2 = texture2D(u_texture1, v_texture);
	
	C1 = premultiply(C1);
	C2 = premultiply(C2);
	
	
	gl_FragColor.r = C1.r > 0.5 ? 1.0 - (1.0 - 2.0 * (C1.r - 0.5)) * (1.0 - C2.r) :  (2.0 * C1.r) * C2.r;
	gl_FragColor.g = C1.g > 0.5 ? 1.0 - (1.0 - 2.0 * (C1.g - 0.5)) * (1.0 - C2.g) :  (2.0 * C1.g) * C2.g;
	gl_FragColor.b = C1.b > 0.5 ? 1.0 - (1.0 - 2.0 * (C1.b - 0.5)) * (1.0 - C2.b) :  (2.0 * C1.b) * C2.b;
	gl_FragColor.a = 1.0;
	
//if (Target > ½) R = 1 - (1-2x(Target-½)) x (1-Blend)
//if (Target <= ½) R = (2xTarget) x Blend	
	
	
	
//    gl_FragColor = (C1 + C2) / 2.0;
	gl_FragColor = C1;
    }
