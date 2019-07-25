#version 150 core

// Taken from: https://github.com/PistonDevelopers/skeletal_animation

// The MIT License (MIT)
// 
// Copyright (c) 2015 PistonDevelopers
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// Dual-Quaternion Linear Blend Skinning
// Reference: http://www.seas.upenn.edu/~ladislav/kavan07skinning/kavan07skinning.pdf

uniform u_Locals {
    mat4 u_Model;
    mat4 u_ViewProj;
    mat4 u_ModelView;
};

uniform u_JointTransforms {
    mat2x4 joint_transforms[MAX_JOINTS];
};

in vec3 a_Pos, a_Normal;
in vec2 a_Uv;

in ivec4 a_JointIndices;
in vec4 a_JointWeights;

out vec3 v_FragPos;
out vec3 v_Normal;
out vec2 v_Uv;

mat4 dualQuaternionToMatrix(vec4 qReal, vec4 qDual) {

    mat4 M = mat4(1.0);

    float len2 = dot(qReal, qReal);
    float w = qReal.x, x = qReal.y, y = qReal.z, z = qReal.w;
    float t0 = qDual.x, t1 = qDual.y, t2 = qDual.z, t3 = qDual.w;

    M[0][0] = w*w + x*x - y*y - z*z; M[0][1] = 2*x*y - 2*w*z; M[0][2] = 2*x*z + 2*w*y;
    M[1][0] = 2*x*y + 2*w*z; M[1][1] = w*w + y*y - x*x - z*z; M[1][2] = 2*y*z - 2*w*x;
    M[2][0] = 2*x*z - 2*w*y; M[2][1] = 2*y*z + 2*w*x; M[2][2] = w*w + z*z - x*x - y*y;

    M[0][3] = -2*t0*x + 2*w*t1 - 2*t2*z + 2*y*t3;
    M[1][3] = -2*t0*y + 2*t1*z - 2*x*t3 + 2*w*t2;
    M[2][3] = -2*t0*z + 2*x*t2 + 2*w*t3 - 2*t1*y;

    M /= len2;

    return M;
}

void main() {
    v_Uv = vec2(a_Uv.x, a_Uv.y);

    float wx = a_JointWeights.x;
    float wy = a_JointWeights.y;
    float wz = a_JointWeights.z;
    float wa = a_JointWeights.a;

    if (dot(joint_transforms[a_JointIndices.x][0],
            joint_transforms[a_JointIndices.y][0]) < 0.0) { wy *= -1; }

    if (dot(joint_transforms[a_JointIndices.x][0],
            joint_transforms[a_JointIndices.z][0]) < 0.0) { wz *= -1; }

    if (dot(joint_transforms[a_JointIndices.x][0],
            joint_transforms[a_JointIndices.a][0]) < 0.0) { wa *= -1; }

    mat2x4 blendedSkinningDQ = joint_transforms[a_JointIndices.x] * wx;
    blendedSkinningDQ += joint_transforms[a_JointIndices.y] * wy;
    blendedSkinningDQ += joint_transforms[a_JointIndices.z] * wz;
    blendedSkinningDQ += joint_transforms[a_JointIndices.a] * wa;
    blendedSkinningDQ /= length(blendedSkinningDQ[0]);

    mat4 blendedSkinningMatrix = dualQuaternionToMatrix(blendedSkinningDQ[0], blendedSkinningDQ[1]);
    vec4 bindPoseVertex = vec4(a_Pos, 1.0);
    vec4 bindPoseNormal = vec4(a_Normal, 0.0);

    vec4 adjustedVertex = bindPoseVertex * blendedSkinningMatrix;
    vec4 adjustedNormal = bindPoseNormal * blendedSkinningMatrix;

    v_FragPos = vec3(u_ViewProj * u_Model * adjustedVertex);
    v_Normal = normalize(u_ModelView * adjustedNormal).xyz;
}
