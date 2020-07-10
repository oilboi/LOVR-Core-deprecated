key_global = 0
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
    --lovr.graphics.setCullingEnabled(true)

    --lovr.graphics.setWireframe(true)
    
    camera = {
        transform = lovr.math.vec3(),
        position = lovr.math.vec3(),
        movespeed = 10,
        pitch = 0,
        yaw = 0
    }    

    dirttexture = lovr.graphics.newTexture("textures/dirt.png")
    dirt = lovr.graphics.newMaterial()
    dirt:setTexture("diffuse", dirttexture)
    chunk_data = {}
    for x = 1,3 do
    chunk_data[x] = {}
    for z = 1,3 do
        chunk_data[x][z] = generate_chunk_vertices()
        chunk_data[x][z]:setMaterial(dirt)
    end
    end
end

function lovr.update(dt)
    camera_look(dt)
    --chunk = generate_chunk_vertices()
    --chunk:setMaterial(dirt)
    --io.write("test\n")
end

function lovr.draw()
    --this is transformed from the camera rotation class
    --mat4(camera.transform):invert()
    --lovr.graphics.transform(x, y, z, sx, sy, sz, angle, ax, ay, az)

    local x,y,z = camera.position:unpack()

    lovr.graphics.rotate(-camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-camera.yaw, 0, 1, 0)

    lovr.graphics.transform(-x,-y,-z)

    lovr.graphics.push()

    lovr.graphics.rotate(1 * math.pi/2, 0, 1, 0)
    lovr.graphics.translate(0,0,0)

    lovr.graphics.print(tostring(key_global), 5, 1.7, 0,1,-90,0,1,0)

    for x,xdata in ipairs(chunk_data) do
    for z,data  in ipairs(xdata) do
        data:draw(x*16,0,z*16)
    end
    end


    lovr.graphics.pop()
end