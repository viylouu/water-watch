#version 430 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNorm;
layout (location = 2) in vec2 aUv;

layout(std140, binding = 0) uniform uni {
    mat4 viewproj;
};

out vec2 fUv;

void main() {
    fUv = aUv;
    gl_Position = viewproj * vec4(aPos + vec3(0,0,-2), 1);
}
