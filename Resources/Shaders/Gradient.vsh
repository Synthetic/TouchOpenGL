attribute vec4 a_position;
uniform mat4 u_projectionMatrix;
varying vec2 v_position;

void main()
{
    v_position = a_position.xy;
    gl_Position = u_projectionMatrix * a_position;
}
