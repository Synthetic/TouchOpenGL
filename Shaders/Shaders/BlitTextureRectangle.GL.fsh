//
//  Shader.fsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#version 150

in vec2 v_texture0;

uniform sampler2DRect u_texture0; //@ name:texture0
uniform vec4 u_color; //@ name:color, usage:color

out vec4 FragColor;

void main()
    {
    FragColor = texture(u_texture0, v_texture0) + u_color;
    }
