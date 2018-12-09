#version 150

uniform sampler2D u_Texture;

in vec2 v_Uv;
in float v_Alpha;

out vec4 Target0;

void main() {
    vec4 color = texture(u_Texture, v_Uv);
    gl_FragColor = vec4(color.xyz, color.a * v_Alpha);
}
