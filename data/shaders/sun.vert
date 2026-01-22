#version 430 core

layout (location = 0) in vec3 aPos;

layout(std140, binding = 0) uniform uni {
    mat4 sun_mvp;
    float time;
    uint obj;
    float yrot;
    vec4 off;
};

void main() {
    vec3 pos = aPos.xyz;
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

    float r = yrot;
    if (r != 0) r += 3.14159;

    float s = sin(r);
    float c = cos(r);

    mat4 rot = mat4(
    c, 0.0, s, 0,
    0.0, 1.0, 0.0, 0,
    -s, 0.0, c, 0,
    0,0,0,1
    );

    mat4 posm = mat4(
    vec4(1,0,0,0),
    vec4(0,1,0,0),
    vec4(0,0,1,0),
    vec4(off.xyz,1)
    );

    pos = (posm * rot * vec4(pos, 1)).xyz;

    pos = round(pos * 32) / 32;

    gl_Position = sun_mvp * vec4(pos, 1);
}
