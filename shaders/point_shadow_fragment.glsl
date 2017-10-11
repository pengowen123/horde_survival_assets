#version 330

in vec4 FragPos;

uniform u_Locals {
	mat4 model;
	vec3 lightPos;
	float farPlane;
};

void main() {
	// Get distance between fragment and light
	float lightDistance = length(FragPos.xyz - lightPos);

	// Normalize to 0 to 1 range
	lightDistance = lightDistance / farPlane;

	gl_FragDepth = lightDistance;
}
