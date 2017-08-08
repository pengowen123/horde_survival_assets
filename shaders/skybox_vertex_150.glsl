#version 150 core

in vec3 a_Pos;

out vec3 v_Uv;

uniform u_Locals {
	mat4 u_ViewProj;
};

void main() {
	v_Uv = a_Pos;

	vec4 pos = u_ViewProj * vec4(a_Pos, 1.0);
	gl_Position = pos.xyww;
}

// vim: ft=glsl
