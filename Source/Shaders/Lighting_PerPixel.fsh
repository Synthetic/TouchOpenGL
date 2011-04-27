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


varying vec4 v_color;
varying vec2 v_texture0;
varying vec4 v_position;
varying vec3 v_normal;

uniform sampler2D s_texture0;

uniform LightSourceParameters u_lightSource; // gl_LightSource
uniform LightModelParameters u_lightModel; // gl_LightModel
uniform MaterialParameters u_frontMaterial; // gl_FrontMaterial
uniform vec4 u_cameraPosition;

uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;

void main()
    {
    gl_FragColor = v_color;

    // Work around for no gl_NormalMatrix from http://glosx.blogspot.com/2008/03/glnormalmatrix.html
    vec3 theNormal = (u_modelViewMatrix * vec4(v_normal, 0.0)).xyz;
    vec3 thePosition = (u_modelViewMatrix * v_position).xyz;
    vec3 theLightDirection = normalize(thePosition - vec3(u_lightSource.position));
    vec3 theViewDirection = normalize(thePosition - vec3(u_cameraPosition));

    // Compute the cos of the angle between the normal and lights direction. The light is directional so the direction is constant for every vertex. Since these two are normalized the cosine is the dot product. We also need to clamp the result to the [0,1] range.
    float NdotL = max(dot(normalize(theNormal), theLightDirection), 0.0);

    // Compute the diffuse term
    vec4 theDiffuseTerm = (u_frontMaterial.diffuse + texture2D(s_texture0, v_texture0)) * u_lightSource.diffuse;

    // Compute the ambient and globalAmbient terms.
    vec4 ambient = (u_frontMaterial.ambient + texture2D(s_texture0, v_texture0)) * u_lightSource.ambient;
    vec4 globalAmbient = (u_frontMaterial.ambient + texture2D(s_texture0, v_texture0)) * u_lightModel.ambient;

    vec3 h = normalize(theLightDirection + theViewDirection);
    float NdotHV = max(dot(theNormal, h), 0.0);
    vec4 specular = u_frontMaterial.specular * u_lightSource.specular * pow(NdotHV,u_frontMaterial.shininess);

    gl_FragColor = NdotL * theDiffuseTerm + globalAmbient + ambient + specular;
    gl_FragColor.a = 1.0;
}
