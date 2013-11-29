#version 330
uniform mat4 posToClip;
uniform mat4 posToCamera;
in vec3 positionAttrib;
in vec3 normalAttrib;
in vec4 vcolorAttrib; // Workaround. "colorAttrib" appears to confuse certain ATI drivers.
in vec2 texCoordAttrib;
out vec3 positionVarying;
out vec3 normalVarying;
out vec4 colorVarying;
out vec3 tangentVarying;
out vec2 texCoordVarying;

void main()
{
	vec4 pos = vec4(positionAttrib, 1.0);
	gl_Position = posToClip * pos;
	positionVarying = (posToCamera * pos).xyz;
	normalVarying = normalAttrib;
	colorVarying = vcolorAttrib;
	texCoordVarying = texCoordAttrib;
	tangentVarying = vec3(1,0,0) - normalAttrib.x*normalAttrib;
}
