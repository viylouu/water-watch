#version 430 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNorm;
layout (location = 2) in vec2 aUv;

layout(std140, binding = 0) uniform uni {
    mat4 viewproj;
    vec3 cam;
    float time;
};

out vec3 fNorm;
out vec2 fUv;
out vec3 fPos;
flat out vec3 fCam;
flat out float fTime;

void main() {
    fNorm = aNorm;
    fUv = aUv;
    fPos = aPos;
    fCam = cam;
    fTime = time;

    vec3 pos = aPos;
    float stime = time * .5;
    pos += vec3(sin(stime + aPos.x * 24), 0, cos(stime + aPos.z * 24)) * .02;
    pos += vec3(cos(stime * 2 + aPos.x * 24), sin(stime * 1.5 + aPos.y * 24), 0) * .03;
    pos = round(pos * 32) / 32;

    gl_Position = viewproj * vec4(pos, 1);
}
