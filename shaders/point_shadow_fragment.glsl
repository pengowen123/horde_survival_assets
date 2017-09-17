#version 330

in vec4 FragPos;

uniform vec3 lightPos;
uniform float farPlane;

void main() {
	// Get distance between fragment and light
	float lightDistance = length(FragPos.xyz - lightPos);

	// Normalize to 0 to 1 range
	lightDistance = lightDistance / farPlane;

	//gl_FragDepth = lightDistance;
	gl_FragDepth = farPlane;
}
