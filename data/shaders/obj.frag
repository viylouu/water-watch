#version 430 core

in vec3 fNorm;
in vec2 fUv;
in vec3 fPos;
flat in vec3 fCam;
flat in float fTime;

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

void main() {
    const vec3 fog = vec3(229 /255., 216 /255., 211 /255.);

    vec3 pos = round(fPos * 32) / 32 * 16;
    float noise = noise(pos);
    noise = floor(noise * 2 + dither4x4x4(pos * 2 + vec3(fTime * 8, 0, 0), noise));
    vec3 col = mix(vec3(.8), vec3(.9), noise);
    col = col * fog;
    
    float bright = dot(fNorm, vec3(-1,-1,-1)) *.2 +.8;
    bright = clamp(bright, .2,1.);
    //float bright = 1;

    float dist = distance(fPos, fCam);
    dist = dist * .14 - .2;
    dist = clamp(dist, 0,1);

    if (dist == 1) discard;

    oCol = vec4(mix(col * bright, fog, dist), 1);
}
