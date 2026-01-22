#version 430 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNorm;
layout (location = 2) in vec2 aUv;
layout (location = 3) in vec3 aCol;

layout(std140, binding = 0) uniform uni {
    mat4 viewproj;
    mat4 sun_biasmvp;
    vec4 cam;
    vec4 sunpos;
    float time;
    uint obj;
    vec4 off;
};

out vec3 fNorm;
out vec2 fUv;
out vec3 fPos;
flat out vec3 fCam;
flat out float fTime;
out vec3 fCol;
flat out uint fId;
flat out uint fObj;
out vec3 fPos2;
flat out vec3 fSunPos;
flat out mat4 fSunBiasMVP;

void main() {
    fNorm = aNorm;
    fUv = aUv;
    fPos = aPos;
    fCam = cam.xyz;
    fTime = time;
    fCol = aCol;
    fId = gl_VertexID;
    fObj = obj;
    fSunPos = sunpos.xyz;
    fSunBiasMVP = sun_biasmvp;

    vec3 pos = aPos + off.xyz;
    float stime = time * .5;
    pos += vec3(sin(stime + aPos.x * 24), 0, cos(stime + aPos.z * 24)) * .02;
    pos += vec3(cos(stime * 2 + aPos.x * 24), sin(stime * 1.5 + aPos.y * 24), 0) * .03;

    if (obj == 1) {
        float t = time * 2;
        pos += vec3(0,1,0) * sin(t + aPos.x*.5) * .6;
        pos -= vec3(0,1,0) * cos(t*1.2 + aPos.z*.8) * .4;
        pos += vec3(0,1,0) * sin(t*.25 + aPos.x*1.2) * .35;
        pos += vec3(0,1,0) * sin(t*.5 + aPos.z*.2) * .7;
        pos -= vec3(0,1,0) * cos(t*4 + aPos.x*4) * .12;
    }

    pos = round(pos * 32) / 32;

    fPos2 = pos;

    gl_Position = viewproj * vec4(pos, 1);
}
