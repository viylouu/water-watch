package models

import "core:fmt"
import "core:strconv"
import "core:strings"

import gl "vendor:OpenGL"

Mesh :: struct{
    verts: []Vertex,
}

Vertex :: struct{
    pos: [3]f32, 
    norm: [3]f32, 
    uv: [2]f32,
}


load_obj :: proc(data: []u8) -> Mesh {
    mesh := Mesh{}

    verts: [dynamic][3]f32
    normals: [dynamic][3]f32
    uvs: [dynamic][2]f32
    tris: [dynamic][9]u32

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        if len(line) <= 0 do continue
        split := strings.split(line, " ")
        switch split[0] {
        case "v":
            x,okx, y,oky, z,okz := strconv.parse_f32(split[1]),
                                   strconv.parse_f32(split[2]),
                                   strconv.parse_f32(split[3])
            assert(okx && oky && okz)

            append(&verts, [3]f32 { x,y,z })
        case "vn":
            x,okx, y,oky, z,okz := strconv.parse_f32(split[1]),
                                   strconv.parse_f32(split[2]),
                                   strconv.parse_f32(split[3])
            assert(okx && oky && okz)

            append(&normals, [3]f32 { x,y,z })
        case "vt":
            u,oku, v,okv := strconv.parse_f32(split[1]),
                            strconv.parse_f32(split[2])
            assert(oku && okv)

            append(&uvs, [2]f32 { u,v })
        case "f":
            parse :: proc(split: []string, i: int) -> (int, int, int) {
                inds := strings.split(split[i], "/")
                v,okv, vt,okvt, vn,okvn := strconv.parse_int(inds[0]),
                                           strconv.parse_int(inds[1]),
                                           strconv.parse_int(inds[2])
                assert(okv && okvn)

                if !okvt do vt = 1

                return v-1, vt-1, vn-1
            }

            a,b,c, d,e,f, g,h,i := parse(split, 1), parse(split, 2), parse(split, 3)
            arr := [?]u32 { u32(a), u32(b), u32(c), 
                            u32(d), u32(e), u32(f),
                            u32(g), u32(h), u32(i) }
            append(&tris, arr)
        }
    }

    if len(uvs) == 0 do append(&uvs, [2]f32 { 0,0 })

    mesh.verts = make([]Vertex, len(tris)*3)

    for i in 0..<len(tris) do for j in 0..<3 {
        a,b,c := tris[i][j*3 +0],
                 tris[i][j*3 +1],
                 tris[i][j*3 +2]

        mesh.verts[i*3 + j] = Vertex{
            pos = verts[a],
            uv = uvs[b],
            norm = normals[c],
        }
    }

    return mesh
}

delete_mesh :: proc(mesh: Mesh) {
    delete(mesh.verts)
}
