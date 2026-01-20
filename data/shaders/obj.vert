#version 430 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNorm;
layout (location = 2) in vec2 aUv;

layout(std140, binding = 0) uniform uni {
    mat4 viewproj;
    vec3 cam;
};

out vec3 fNorm;
out vec2 fUv;
out vec3 fPos;
flat out vec3 fCam;

void main() {
    fNorm = aNorm;
    fUv = aUv;
    fPos = aPos;
    fCam = cam;
    gl_Position = viewproj * vec4(aPos, 1);
}
