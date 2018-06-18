#version 330

uniform u_Locals {
	mat4 u_Proj;
	mat4 u_View;
};

in vec4 a_Pos;

smooth out vec3 v_EyeDirection;

void main() {
    mat4 inverseProj = inverse(u_Proj);
    mat3 inverseView = transpose(mat3(u_View));
    vec3 unprojected = (inverseProj * a_Pos).xyz;
    v_EyeDirection = inverseView * unprojected;

    gl_Position = vec4(a_Pos.xy, 1.0, 1.0);
} 
