#version 150

in vec2 a_Pos;
in vec2 a_Uv;
in vec4 a_Color;

out vec2 v_Uv;
out vec4 v_Color;

void main() {
	v_Uv = a_Uv;
	v_Color = a_Color;
	gl_Position = vec4(a_Pos, 0.0, 1.0);
}
