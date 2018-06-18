#version 330

uniform samplerCube t_Skybox;

smooth in vec3 v_EyeDirection;

out vec4 Target0;

void main() {
    Target0 = texture(t_Skybox, v_EyeDirection);
}
