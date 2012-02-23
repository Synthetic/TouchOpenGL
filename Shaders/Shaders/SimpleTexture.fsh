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

uniform sampler2D u_texture0;

void main()
    {
    gl_FragColor = texture2D(u_texture0, v_texture0);
    gl_FragColor.b = texture2D(u_texture0, vec2(v_texture0.x - 0.1, v_texture0.y)).b;
    }
