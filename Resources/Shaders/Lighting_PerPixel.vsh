#ifdef GL_ES
precision mediump float;
#endif

struct LightSourceParameters {
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    vec4 position;
    };

struct LightModelParameters {
    vec4 ambient;
	};

struct MaterialParameters {
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
	};

// ######################################################################

varying vec2 v_texture0;
varying vec4 v_position;
varying vec3 v_normal;

attribute vec4 a_position;
attribute vec3 a_normal; // gl_Normal
attribute vec2 a_texCoord; // gl_Normal

uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;
//uniform mat3 u_normalMatrix; // gl_NormalMatrix

uniform LightSourceParameters u_lightSource; // gl_LightSource
uniform LightModelParameters u_lightModel; // gl_LightModel
uniform MaterialParameters u_frontMaterial; // gl_FrontMaterial
uniform vec4 u_cameraPosition;

void main()
{
    mat4 theModelViewProjectionMatrix = u_projectionMatrix * u_modelViewMatrix;
    gl_Position = theModelViewProjectionMatrix * a_position;

    v_texture0 = a_texCoord;
    v_position = a_position;
    v_normal = a_normal;
}



