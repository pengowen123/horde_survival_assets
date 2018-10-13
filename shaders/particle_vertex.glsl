#version 150

in vec3 a_Pos;
in vec3 a_Translate;
in uint a_Color;
in float a_Alpha;

uniform u_Locals {
    mat4 u_ViewProj;
    vec3 u_CameraRightWorldSpace;
    vec3 u_CameraUpWorldSpace;
    float u_Scale;
};

out vec4 v_Color;

void main() {
    gl_Position = u_ViewProj * vec4(
        a_Translate
        + u_CameraRightWorldSpace * a_Pos.x * u_Scale
        + u_CameraUpWorldSpace * a_Pos.y * u_Scale,
        1.0
    );

    uint u8mask = 0x000000FFu;
    v_Color = vec4(
        float((a_Color >> 16) & u8mask),
        float((a_Color >>  8) & u8mask),
        float( a_Color & u8mask),
        0.0
    ) / 255.0;
    v_Color.a = a_Alpha;
}
