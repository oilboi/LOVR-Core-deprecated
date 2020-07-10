vertex_exact_count = 0
chunksize = 2
lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

lovr.graphics.setDefaultFilter("nearest", 0)

require 'chunk_vertice_generator'
require 'input'
require 'camera'

local chunk_size = chunksize

--local chunk


function lovr.load()
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)

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
    for x = 1,14 do
    chunk_data[x] = {}
    for y = 1,3 do
    chunk_data[x][y] = {}
    for z = 1,14 do
    chunk_data[x][y][z] = generate_chunk_vertices()
    chunk_data[x][y][z]:setMaterial(dirt)
    end
    end
    end
end

local counter = 0
local up = true
function lovr.update(dt)
    camera_look(dt)
    if up then
        counter = counter + dt/5
    else
        counter = counter - dt/5
    end
    if counter >= 0.4 then
        up = false
    elseif counter <= 0 then
        up = true
    end
    --chunk = generate_chunk_vertices()
    --chunk:setMaterial(dirt)
    --io.write("test\n")
end

local predef = chunk_size * 7
function lovr.draw()
    --this is transformed from the camera rotation class
    --mat4(camera.transform):invert()
    --lovr.graphics.transform(x, y, z, sx, sy, sz, angle, ax, ay, az)

    local x,y,z = camera.position:unpack()

    --x = x + math.random()*math.random()
    --y = y + math.random()*math.random()
    --z = z + math.random()*math.random()

    lovr.graphics.rotate(-camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-camera.yaw, 0, 1, 0)

    lovr.graphics.transform(-x,-y,-z)

    lovr.graphics.push()

    lovr.graphics.rotate(1 * math.pi/2, 0, 1, 0)
    lovr.graphics.translate(0,0,0)

    for x,xdata in ipairs(chunk_data) do
    for y,ydata in ipairs(xdata) do
    for z,data  in ipairs(ydata) do
        data:draw(x*chunk_size-predef,y*chunk_size-predef,z*chunk_size-predef)
    end
    end
    end

    local dir = {x=math.cos(-camera.yaw),z=math.sin(-camera.yaw),y=math.sin(camera.pitch)}
    
    dir.x = dir.x * 2
    dir.y = dir.y * 2
    dir.z = dir.z * 2

    local pos = {x=-z+dir.x,y=y+dir.y,z=x+dir.z}


    --lovr.graphics.print(tostring(vertex_exact_count), pos.x, pos.y, pos.z,1,-90,0,1,0)

    lovr.graphics.cube('line',  pos.x, pos.y+counter, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end