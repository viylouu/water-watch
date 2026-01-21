#version 430 core

layout (location = 0) in vec3 aPos;

layout(std140, binding = 0) uniform uni {
    mat4 sun_mvp;
    float time;
    uint obj;
};

void main() {
    vec3 pos = aPos;
    //float stime = time * .5;
    //pos += vec3(sin(stime + aPos.x * 24), 0, cos(stime + aPos.z * 24)) * .02;
    //pos += vec3(cos(stime * 2 + aPos.x * 24), sin(stime * 1.5 + aPos.y * 24), 0) * .03;

    /*if (obj == 1) {
        float t = time * 2;
        pos += vec3(0,1,0) * sin(t + aPos.x*.5) * .6;
        pos -= vec3(0,1,0) * cos(t*1.2 + aPos.z*.8) * .4;
        pos += vec3(0,1,0) * sin(t*.25 + aPos.x*1.2) * .35;
        pos += vec3(0,1,0) * sin(t*.5 + aPos.z*.2) * .7;
        pos -= vec3(0,1,0) * cos(t*4 + aPos.x*4) * .12;
    }*/

    pos = round(pos * 32) / 32;

    gl_Position = sun_mvp * vec4(pos, 1);
}
