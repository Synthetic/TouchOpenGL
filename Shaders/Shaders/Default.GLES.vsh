//
//  Shader.vsh
//  Dwarfs
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

attribute vec4 a_position; //@ name:positions
attribute vec2 a_texCoord; //@ name:texCoords

uniform mat4 u_modelViewMatrix; //@ name:modelViewMatrix
uniform mat4 u_projectionMatrix; //@ name:projectionMatrix

varying vec2 v_texture0;

void main()
    {
    v_texture0 = a_texCoord;
    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_position;
    }