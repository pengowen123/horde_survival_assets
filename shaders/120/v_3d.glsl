#version 120

uniform mat4 u_Transform;

attribute vec4 a_Pos;
attribute vec2 a_Uv;
varying vec2 v_Uv;

void main() {
    v_Uv = a_Uv;
	gl_Position = u_Transform * a_Pos;
}
