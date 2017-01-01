#version 120

uniform sampler2D t_Color;

varying vec2 v_Uv;
varying vec4 v_Color;

void main() {
	vec4 tex = texture2D(t_Color, v_Uv);
	gl_FragColor = tex + v_Color - vec4(0.0, 0.0, 0.0, 1.0);
}
