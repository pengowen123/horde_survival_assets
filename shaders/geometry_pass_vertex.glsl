#version 330 core

in vec3 a_Pos;
in vec3 a_Normal;
in vec2 a_Uv;

out vec3 v_FragPos;
out vec3 v_Normal;
out vec2 v_Uv;

uniform u_Locals {
    mat4 u_Model;
    mat4 u_ViewProj;
};

void main() {
    vec4 worldPos = u_Model * vec4(a_Pos, 1.0);

    v_FragPos = worldPos.xyz;
    v_Uv = a_Uv;

    // TODO: Make this a uniform to avoid recalculating per vertex
    mat3 normalMatrix = inverse(transpose(mat3(u_Model)));
    v_Normal = normalMatrix * a_Normal;

    gl_Position = u_ViewProj * worldPos;
}
