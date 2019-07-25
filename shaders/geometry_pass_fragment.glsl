#version 330 core
// TODO: try to make this work on 150

in vec3 v_FragPos;
in vec3 v_Normal;
in vec2 v_Uv;

// Gbuffer position
layout (location = 0) out vec4 Target0;
// Gbuffer normal
layout (location = 1) out vec4 Target1;
// Gbuffer color + specular
layout (location = 2) out vec4 Target2;

uniform sampler2D t_Diffuse;
uniform sampler2D t_Specular;

void main() {
    Target0 = vec4(v_FragPos, 1.0);
    Target1 = vec4(normalize(v_Normal), 1.0);
    Target2.rgb = texture(t_Diffuse, v_Uv).rgb;
    Target2.a = texture(t_Specular, v_Uv).r;
}
