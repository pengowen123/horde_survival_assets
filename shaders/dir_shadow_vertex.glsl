#version 330

// NOTE: The layout specifier may be important for correctness when sharing the same vertex types
//       between shaders
layout (location = 0) in vec3 a_Pos;

uniform u_Locals {
    mat4 lightSpaceMatrix;
    mat4 model;
};

void main() {
    gl_Position = lightSpaceMatrix * model * vec4(a_Pos, 1.0);
}
