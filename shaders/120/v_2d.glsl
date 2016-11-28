#version 120

attribute vec2 a_Pos;
attribute vec2 a_Uv;
attribute vec4 a_Color;

varying vec2 v_Uv;
varying vec4 v_Color;

void main() {
	v_Uv = a_Uv;
	v_Color = a_Color;
	gl_Position = vec4(a_Pos, 0.0, 1.0);
}
