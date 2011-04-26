#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_position;

void main()
{
	float r = sqrt(dot(v_position, v_position)) / 10.0;
    gl_FragColor = (1.0 - r) * vec4(1.0, 1.0, 1.0, 1.0) + r * vec4(0.8, 0.8, 0.8, 1.0);
}
