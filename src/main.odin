package main

import "core:fmt"

import "core:math/linalg/glsl"

import "../eat"
import "../eat/core/eaw"
import "../eat/core/ear"

import "models"

main :: proc() {
    eat.init(
            800, 600,
            "3d game",
        )
    defer eat.stop()

    model := models.load_obj(#load("../data/models/ico.obj"))
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

    for eat.frame() {
        ear.clear([3]f32{ .2, .4, .3 })

        pln_data.viewproj = glsl.mat4Perspective(90 * (3.14159 / 180.), f32(eaw.width)/f32(eaw.height), .1, 1000)

        ear.update_buffer(&ubo)

        ear.bind_pipeline(pln)
        ear.bind_buffer(ubo, 0)
        ear.draw(len(model.verts))
    }
}
