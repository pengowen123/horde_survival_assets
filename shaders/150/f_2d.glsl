#version 150

uniform sampler2D t_Color;

in vec2 v_Uv;
in vec4 v_Color;

void main() {
	vec4 tex = texture(t_Color, v_Uv);
	gl_FragColor = tex + v_Color - vec4(0.0, 0.0, 0.0, 1.0);
}
