lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

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
    dirt = lovr.graphics.newMaterial('textures/dirt.png')
    chunk = generate_chunk_vertices()
    chunk:setMaterial(dirt)
end

function lovr.update(dt)
    camera_look(dt)
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