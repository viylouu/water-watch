#version 430 core

in vec2 fUv;

out vec4 oCol;

void main() {
    oCol = vec4(fUv, 0,1);
}
