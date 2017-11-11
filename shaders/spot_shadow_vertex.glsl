#version 330

layout (location = 0) in vec3 a_Pos;

uniform u_Locals {
	mat4 lightSpaceMatrix;
	mat4 model;
};

void main() {
	gl_Position = lightSpaceMatrix * model * vec4(a_Pos, 1.0);
}
