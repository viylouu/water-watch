#version 430 core

in vec2 fUv;

layout(std140, binding = 0) uniform uni {
    mat4 inv_proj;
    mat4 view;
    vec4 sunpos;
    float time;
};

out vec4 oCol;

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
    const vec3 fog = vec3(.319, .39, .5);

    vec2 ndc = fUv * 2 - 1;
    vec4 clip = vec4(ndc, 0, 1);
    vec4 viewp = inv_proj * clip;
    viewp.xyz /= viewp.w;
    mat3 viewrot = mat3(view);
    vec3 norm = normalize(viewp.xyz * viewrot);

    vec3 sun = normalize(sunpos.xyz);

    float bright = pow(clamp(dot(norm, sun), 0,1), 12);
    oCol = vec4(mix(vec3(252/255.,195/255.,138/255.), vec3(1), bright + .4 * dither4x4x4(norm * 128 + vec3(time*4), round(bright*4)/4)), 1);

    if (norm.y < 0) oCol = vec4(mix(fog, oCol.rgb, clamp(.8 + 12 * norm.y, 0,1)), 1);
}
