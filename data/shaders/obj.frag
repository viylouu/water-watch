#version 430 core

in vec3 fNorm;
in vec2 fUv;
in vec3 fPos;
flat in vec3 fCam;
flat in float fTime;
in vec3 fCol;
flat in uint fId;
flat in uint fObj;
in vec3 fPos2;

out vec4 oCol;

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float dither4x4x4(vec3 position, float brightness) {
    int x = int(mod(position.x, 4.0));
    int y = int(mod(position.y, 4.0));
    int z = int(mod(position.z, 4.0));

    int index = x + y * 4 + z * 16;
    float limit = 0.0;

    // 4x4x4 bayer matrix, values in range (0, 1]
    // generated from standard recursive bayer construction
    float bayer[64] = float[64](
         1, 33,  9, 41, 49, 17, 57, 25, 13, 45,  5, 37, 61, 29, 53, 21,
        17, 49, 25, 57,  9, 41,  1, 33, 29, 61, 21, 53,  5, 37, 13, 45,
         5, 37, 13, 45, 61, 29, 53, 21,  1, 33,  9, 41, 49, 17, 57, 25,
        21, 53, 29, 61, 13, 45,  5, 37, 25, 57, 17, 49,  9, 41,  1, 33
    );

    limit = bayer[index] / 64.0;
    return brightness < limit ? 0.0 : 1.0;
}

float rand(float co){
    return fract(sin(dot(vec2(co,0), vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    float dist = distance(fPos, -fCam);
    float cdist = clamp(dist * .08 - 5, 0,1);
    if (cdist == 1) discard;
    cdist = pow(cdist, .14);

    const vec3 fog = vec3(.319, .39, .5);

    vec3 pos = round(fPos * 32) / 32 * 16;
    vec3 ditherpos = pos * 2 + vec3(fNorm.z, fNorm.y, fNorm.x) * fTime * 8;
    float n = noise(pos * vec3(abs(fNorm.z)*.25 + abs(fNorm.x)*1 + abs(fNorm.y)*.25, 1.5, abs(fNorm.z)*1 + abs(fNorm.x)*.25 + abs(fNorm.y)*1.5));
    n = floor(n * 2 + dither4x4x4(ditherpos, n));
    vec3 col = mix(vec3(.8), vec3(.9), n);
    col = col * fCol;
    
    float bright = dot(fNorm, normalize(vec3(-.5,1,-.75))) *.2 +.8;
    bright = clamp(bright, .2,1.);
    //float bright = 1;

    if (fObj == 1) {
        ditherpos -= vec3(0,fNorm.y,0) * fTime * 8;
        ditherpos /= floor(clamp(pow(dist, 1.15) * .15, 1,8));
        col += .1 * dither4x4x4(ditherpos, clamp((fPos2.y +10) * .5 + .5, 0,1));
        vec3 t = -vec3(fTime, 0, fTime);
        col -= .05 * vec3(noise(pos/32 + t * 2) + noise(pos/8 + t * 4) + noise(pos/12 + t * 2));
    }

    oCol = vec4(mix(col * bright, fog, cdist), 1);
}
