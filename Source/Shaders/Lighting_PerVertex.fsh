#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_color;
varying vec2 v_texture0;

uniform sampler2D s_texture0;

void main()
    {
    gl_FragColor = texture2D(s_texture0, v_texture0) + v_color;
    }
