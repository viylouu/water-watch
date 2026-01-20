#version 430 core

in vec3 fNorm;
in vec2 fUv;

out vec4 oCol;

void main() {
    oCol = vec4(fNorm * .5 + .5,1);
}
