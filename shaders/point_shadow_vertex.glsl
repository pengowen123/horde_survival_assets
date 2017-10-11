#version 330

layout (location = 0) in vec3 a_Pos;

uniform u_Locals {
	mat4 model;
	vec3 lightPos;
	float farPlane;
};

void main() {
	gl_Position = model * vec4(a_Pos, 1.0);
}
