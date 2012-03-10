//
//  Shader.fsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#ifdef GL_ES
precision mediump float;
#define TEXTURE2D texture2D
#define SAMPLER2D sampler2D
#else
#define TEXTURE2D texture2DRect
#define SAMPLER2D sampler2DRect
#endif


varying vec2 v_texture0;

// uniform sampler2D u_texture0;
uniform SAMPLER2D u_texture0;

void main()
    {
    gl_FragColor = TEXTURE2D(u_texture0, v_texture0);
    }
