lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

lovr.graphics.setDefaultFilter("nearest", 0)

require 'chunk_vertice_generator'
require 'input'
require 'camera'

local chunksize = 16
local chunk

function lovr.load()
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)

    --lovr.graphics.setWireframe(true)

    camera = {
        transform = lovr.math.newMat4(),
        position = lovr.math.newVec3(),
        movespeed = 10,
        pitch = 0,
        yaw = 0
    }

    dirttexture = lovr.graphics.newTexture("textures/dirt.png")
    dirt = lovr.graphics.newMaterial()
    dirt:setTexture("diffuse", dirttexture)
    chunk = generate_chunk_vertices()
    chunk:setMaterial(dirt)
end

function lovr.update(dt)
    camera_look(dt)
    --chunk = generate_chunk_vertices()
    --chunk:setMaterial(dirt)
end

function lovr.draw()
    

    --this is transformed from the camera rotation class
    lovr.graphics.transform(mat4(camera.transform):invert())
    lovr.graphics.push()
    lovr.graphics.rotate(1 * math.pi/2, 0, 1, 0)
    lovr.graphics.translate(3,0,0)

    chunk:draw(0,0,0)
    lovr.graphics.pop()
end