#version 150

in vec3 a_Pos;
in vec2 a_Uv;
in vec3 a_Translate;
in float a_Alpha;

uniform u_Locals {
    mat4 u_ViewProj;
    vec3 u_CameraRightWorldSpace;
    vec3 u_CameraUpWorldSpace;
    float u_Scale;
};

out vec2 v_Uv;
out float v_Alpha;

void main() {
    gl_Position = u_ViewProj * vec4(
        a_Translate
        + u_CameraRightWorldSpace * a_Pos.x * u_Scale
        + u_CameraUpWorldSpace * a_Pos.y * u_Scale,
        1.0
    );

    v_Uv = a_Uv;
    v_Alpha = a_Alpha;
}
