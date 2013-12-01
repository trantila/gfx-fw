#version 330
// control
uniform bool hasNormals;
uniform bool useDiffuseTexture;
uniform bool useNormalMap;
uniform bool setDiffuseToZero;
uniform bool setSpecularToZero;

// 0: with lighting, 1: diffuse texture only,
// 2: normal map texture only, 3: final normal only
uniform int renderMode;

// material parameters
uniform vec4 diffuseUniform;
uniform vec3 specularUniform;
uniform mat3 normalToCamera;
uniform mat4 posToCamera;
uniform float glossiness;

// how deep the normal mapped bumps are
uniform float normalMapScale;

// texture samplers
uniform sampler2D diffuseSampler;
uniform sampler2D normalSampler;

// lighting information, in camera space
uniform int  numLights;
uniform vec3 lightIntensities[8];
uniform vec3 lightDirections[8];

// interpolated inputs from vertex shader
in vec3 positionVarying;
in vec3 normalVarying;
in vec4 colorVarying;
in vec3 tangentVarying;
in vec2 texCoordVarying;

// output color
out vec4 outColor;

void main()
{
	vec4 diffuseColor = diffuseUniform * colorVarying;
	vec3 specularColor = specularUniform;

	if (useDiffuseTexture)
	{
		// YOUR CODE HERE (R1)
		// Fetch the diffuse material color for the fragment.
		// This is just one line of code.
		diffuseColor = texture(diffuseSampler, texCoordVarying);
	}

	// diffuse only?
	if (renderMode == 1)
	{
		outColor = vec4(diffuseColor.rgb, 1);
		return;
	}

	// this is just interpolated between the vertices
	vec3 mappedNormal = normalize(normalVarying);

	if (useNormalMap)
	{
		// YOUR CODE HERE (R2)
		// Fetch the object space normal from the normal map and scale it.
		// Then transform to camera space and assign to mappedNormal.
		// Don't forget to normalize!
		vec3 normalFromTexture = ((texture(normalSampler, texCoordVarying)-0.5)*2.0).xyz; //vec3(0.0);
		mappedNormal = normalToCamera * normalFromTexture;

		if (renderMode == 2)
		{
			outColor = vec4(normalFromTexture*0.5+0.5, 1);
			return;
		}
	}

	if (renderMode == 3)
	{
		outColor = vec4(mappedNormal*0.5+0.5, 1);
		return;
	}
					
	vec3 N = mappedNormal;

	// YOUR CODE HERE (R4)
	// Compute the to-viewer vector V which you'll need in the loop
	// below for Blinn-Phong specular computation.
	vec3 V = normalize((posToCamera * vec4(positionVarying, 1)).xyz - positionVarying); //vec3(0.0);

	// loop over each light, add their contribution here
	vec3 L = vec3(0.0);

	for (int i = 0; i < numLights; ++i)
	{
		// YOUR CODE HERE (R3)
		// Compute the contribution of this light to diffuse shading.
		// This is just one row of code.
		vec3 diffuse = diffuseColor.xyz * max(dot(N, lightDirections[i]), 0.0); //vec3(0.0);

		// YOUR CODE HERE (R4)
		// Compute the contribution of this light to Blinn-Phong (half-angle) specular shading.
		vec3 H = normalize(V+lightDirections[i]);
		vec3 specular = specularColor.xyz * pow(max(dot(H,N), 0.0), glossiness); //vec3(0, 0, 0);

		if (setDiffuseToZero)
			diffuse = vec3(0, 0, 0);

		if (setSpecularToZero)
			specular = vec3(0, 0, 0);

		L += lightIntensities[i] * (diffuse + specular);
	}
	outColor = vec4(L, 1);
}
				