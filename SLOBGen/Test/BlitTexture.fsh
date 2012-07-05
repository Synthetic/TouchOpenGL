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

void main()
    {
    gl_FragColor = texture2D(u_texture0, v_texture0);
    }
