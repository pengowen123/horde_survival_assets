#version 150 core

in vec3 v_Uv;

out vec4 Target0;

uniform samplerCube t_Skybox;

void main() {
	Target0 = vec4(vec3(texture(t_Skybox, v_Uv).r), 1.0);
}
