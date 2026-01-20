package main

import "core:fmt"

import "core:math"
import "core:math/linalg/glsl"

import "../eat"
import "../eat/core/eaw"
import "../eat/core/ear"

import "models"

main :: proc() {
    eat.init(
            800, 600,
            "3d game",
            { vsync = false },
        )
    defer eat.stop()

    model := models.load_obj(#load("../data/models/santa.obj"))
    defer models.delete_mesh(model)

    vert := #load("../data/shaders/obj.vert", cstring)
    frag := #load("../data/shaders/obj.frag", cstring)

    vbo := ear.create_buffer({
            type = .Vertex,
            usage = .Static,
            stride = size_of(models.Vertex),
        }, &model.verts[0], size_of(models.Vertex) * u32(len(model.verts)))
    defer ear.delete_buffer(vbo)

    pln := ear.create_pipeline({
            vertex = { source = &vert },
            fragment = { source = &frag },
            vertex_attribs = []ear.VertexAttribDesc {
                ear.VertexAttribDesc{ buffer = &vbo, location = 0, type = .Float, components = 3, norm = false, stride = size_of(models.Vertex), offset = 0 * size_of(f32), },
                ear.VertexAttribDesc{ buffer = &vbo, location = 1, type = .Float, components = 3, norm = false, stride = size_of(models.Vertex), offset = 3 * size_of(f32), },
                ear.VertexAttribDesc{ buffer = &vbo, location = 2, type = .Float, components = 2, norm = false, stride = size_of(models.Vertex), offset = 6 * size_of(f32), },
            },
            depth = true,
            cull_mode = .Back,
            front = .CCW,
        })
    defer ear.delete_pipeline(pln)

    pln_data: struct{
        viewproj: glsl.mat4
    }

    ubo := ear.create_buffer({
        type = .Uniform,
        usage = .Dynamic,
        stride = size_of(pln_data),
    }, &pln_data, size_of(pln_data))
    defer ear.delete_buffer(ubo)

    pos: [3]f32
    rot: [3]f32

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        pln_data.viewproj = glsl.mat4Perspective(90 * (3.14159 / 180.), f32(eaw.width)/f32(eaw.height), .1, 1000) * 
                            glsl.mat4Rotate({ 1,0,0 }, rot.x) * glsl.mat4Rotate({ 0,1,0 }, rot.y) * 
                            glsl.mat4Rotate({ 0,0,1 }, rot.z) * glsl.mat4Translate(pos)

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

        ear.bind_pipeline(pln)
        ear.bind_buffer(ubo, 0)
        ear.draw(len(model.verts))

        fmt.println(math.round(1/eaw.delta), "fps")
    }
}
