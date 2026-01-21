package main

import "core:fmt"

import "core:math"
import "core:math/linalg/glsl"

import "../eat"
import "../eat/core/eaw"
import "../eat/core/ear"

import "models"

FullMesh :: struct{
    mesh: ^models.Mesh,
    vbo: ear.Buffer,
    pln: ear.Pipeline,
}

main :: proc() {
    eat.init(
            800, 600,
            "3d game",
            { vsync = false },
        )
    defer eat.stop()

    mods := models.load_obj(#load("../data/models/santa.obj"))
    defer models.delete_meshes(mods[:])

    meshes := make([]FullMesh, len(mods))
    for &mesh, i in meshes {
        vert := #load("../data/shaders/obj.vert", cstring)
        frag := #load("../data/shaders/obj.frag", cstring)

        mesh.mesh = &mods[i]
        if len(mesh.mesh.verts) == 0 do continue

        mesh.vbo = ear.create_buffer({
                type = .Vertex,
                usage = .Static,
                stride = size_of(models.Vertex),
            }, &mesh.mesh.verts[0], size_of(models.Vertex) * u32(len(mesh.mesh.verts)))
        //defer ear.delete_buffer(mesh.vbo)

        mesh.pln = ear.create_pipeline({
                vertex = { source = &vert },
                fragment = { source = &frag },
                vertex_attribs = []ear.VertexAttribDesc {
                    ear.VertexAttribDesc{ buffer = &mesh.vbo, location = 0, type = .Float, components = 3, norm = false, stride = size_of(models.Vertex), offset = 0 * size_of(f32), },
                    ear.VertexAttribDesc{ buffer = &mesh.vbo, location = 1, type = .Float, components = 3, norm = false, stride = size_of(models.Vertex), offset = 3 * size_of(f32), },
                    ear.VertexAttribDesc{ buffer = &mesh.vbo, location = 2, type = .Float, components = 2, norm = false, stride = size_of(models.Vertex), offset = 6 * size_of(f32), },
                    ear.VertexAttribDesc{ buffer = &mesh.vbo, location = 3, type = .Float, components = 3, norm = false, stride = size_of(models.Vertex), offset = 8 * size_of(f32), },
                },
                depth = true,
                cull_mode = .Back,
                front = .CCW,
            })
        //defer ear.delete_pipeline(mesh.pln)
    }
    defer for &mesh in meshes {
        ear.delete_pipeline(mesh.pln)
        ear.delete_buffer(mesh.vbo)
    }

    defer delete(meshes)

    pln_data: struct{
        viewproj: glsl.mat4,
        cam: [3]f32,
        time: f32,
    }

    ubo := ear.create_buffer({
        type = .Uniform,
        usage = .Dynamic,
        stride = size_of(pln_data),
    }, &pln_data, size_of(pln_data))
    defer ear.delete_buffer(ubo)

    pos: [3]f32
    rot: [3]f32


    fbcol := ear.create_texture({
            filter = .Nearest,
            type = .Color,
        }, nil, 640, 360)
    fbdepth := ear.create_texture({
            filter = .Nearest,
            type = .Depth,
        }, nil, 640, 360)
    defer { ear.delete_texture(fbcol) ;; ear.delete_texture(fbdepth) }
    fb := ear.create_framebuffer({
            out_colors = { &fbcol },
            out_depth = &fbdepth,
        })
    defer ear.delete_framebuffer(fb)

    fbvert := #load("../data/shaders/post.vert", cstring)
    fbfrag := #load("../data/shaders/post.frag", cstring)

    fbpln := ear.create_pipeline({
            vertex = { source = &fbvert },
            fragment = { source = &fbfrag },
        })
    defer ear.delete_pipeline(fbpln)


    for eat.frame() {
        ear.bind_framebuffer(fb)
        ear.clear([3]f32{ 229 /255., 216 /255., 211 /255. })

        pln_data.viewproj = glsl.mat4Perspective(90 * (3.14159 / 180.), 640./360., .1, 1000) * 
                            glsl.mat4Rotate({ 1,0,0 }, rot.x) * glsl.mat4Rotate({ 0,1,0 }, rot.y) * 
                            glsl.mat4Rotate({ 0,0,1 }, rot.z) * glsl.mat4Translate(pos)
        pln_data.cam = -pos
        pln_data.time = eaw.time

        sind, cosd := math.sin(rot.y), math.cos(rot.y)
        speed, rspeed :: 4., 2.

        if eaw.is_key(.W) do pos += [3]f32{ -sind, 0, cosd } * eaw.delta * speed
        if eaw.is_key(.S) do pos -= [3]f32{ -sind, 0, cosd } * eaw.delta * speed
        if eaw.is_key(.A) do pos += [3]f32{ cosd, 0, sind } * eaw.delta * speed
        if eaw.is_key(.D) do pos -= [3]f32{ cosd, 0, sind } * eaw.delta * speed

        if eaw.is_key(.Space) do pos.y -= eaw.delta * speed
        if eaw.is_key(.LShift) do pos.y += eaw.delta * speed

        if eaw.is_key(.Left) do rot.y -= eaw.delta * rspeed
        if eaw.is_key(.Right) do rot.y += eaw.delta * rspeed
        if eaw.is_key(.Up) do rot.x -= eaw.delta * rspeed
        if eaw.is_key(.Down) do rot.x += eaw.delta * rspeed

        ear.update_buffer(&ubo)
        ear.bind_buffer(ubo, 0)
        for mesh in meshes {
            ear.bind_pipeline(mesh.pln)
            ear.draw(len(mesh.mesh.verts))
        }

        fmt.println(math.round(1/eaw.delta), "fps")

        ear.bind_framebuffer(nil)
        ear.bind_pipeline(fbpln)
        ear.bind_texture(fbcol, 0)
        ear.draw(6)
    }
}
