#version 430 core

const vec2 verts[6] = vec2[6](
        vec2(0,0), vec2(1,0),
        vec2(1,1), vec2(1,1),
        vec2(0,1), vec2(0,0)
    );

out vec2 fUv;

void main() {
    vec2 vert = verts[gl_VertexID];

    gl_Position = vec4(vert * 2 - 1, 0,1);

    fUv = vert;
}
