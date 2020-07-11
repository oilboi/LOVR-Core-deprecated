global_time_print = 0
chunksize = 16

local chunk_size = chunksize

lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

lovr.graphics.setDefaultFilter("nearest", 0)

require 'chunk_vertice_generator'
require 'input'
require 'camera'



function hash_position(x,y,z)
	return (z + 32768) * 65536 * 65536
		 + (y + 32768) * 65536
		 +  x + 32768
end

function get_position_from_hash(hash)
	local x = (hash % 65536) - 32768
	hash  = math.floor(hash / 65536)
	local y = (hash % 65536) - 32768
	hash  = math.floor(hash / 65536)
	local z = (hash % 65536) - 32768
	return x,y,z
end


local chunk_pool = {}

function gen_chunk_data()
    local chunk_data = {}
    for x = 1,chunk_size do
    chunk_data[x] = {}
    for y = 1,chunk_size do
    chunk_data[x][y] = {}
    for z = 1,chunk_size do
    chunk_data[x][y][z] = lovr.math.random(1,2)
    end
    end
    end
    return(chunk_data)
end


function gen_chunk(x,y,z)
    local ref = hash_position(x,y,z)
    chunk_pool[ref] = {}
    
    local chunk_data = gen_chunk_data()
    
    chunk_pool[ref].data = chunk_data
    
    chunk_pool[ref].mesh = generate_chunk_vertices(chunk_data,x*chunk_size,y*chunk_size,z*chunk_size)

    chunk_pool[ref].mesh:setMaterial(dirt)
end

function lovr.load()
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)
    lovr.graphics.setBlendMode(nil,nil)

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
    dirt:setTexture(dirttexture)
    
end

local counter = 0
local up = true
local time_delay = 0
local curr_chunk_index = {x=-2,y=-2,z=-2}
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
    if time_delay then
        time_delay = time_delay + dt
        if time_delay >= 0.25 then
            time_delay = 0
            gen_chunk(curr_chunk_index.x,curr_chunk_index.y,curr_chunk_index.z)

            curr_chunk_index.x = curr_chunk_index.x + 1
            if curr_chunk_index.x > 2 then
                curr_chunk_index.x = -2
                curr_chunk_index.y = curr_chunk_index.y + 1
                if curr_chunk_index.y > 2 then
                    curr_chunk_index.y = -2
                    curr_chunk_index.z = curr_chunk_index.z + 1
                    if curr_chunk_index.z > 2 then
                        time_delay = nil
                    end
                end
            end
        end
    end
end

--local predef = chunk_size * number_of_chunks


function lovr.draw()
    --this is transformed from the camera rotation class
    --mat4(camera.transform):invert()
    --lovr.graphics.transform(x, y, z, sx, sy, sz, angle, ax, ay, az)
   -- local time = lovr.timer.getTime()

    local x,y,z = camera.position:unpack()

    lovr.graphics.rotate(-camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-camera.yaw, 0, 1, 0)

    lovr.graphics.transform(-x,-y,-z)

    lovr.graphics.rotate(1 * math.pi/2, 0, 1, 0)
    for _,data in pairs(chunk_pool) do
        lovr.graphics.push()
        data.mesh:draw()
        lovr.graphics.pop()
    end

    lovr.graphics.push()

    local dir = {x=math.cos(-camera.yaw),z=math.sin(-camera.yaw),y=math.sin(camera.pitch)}
    
    dir.x = dir.x * 4
    dir.y = dir.y * 4
    dir.z = dir.z * 4

    local pos = {x=-z+dir.x,y=y+dir.y,z=x+dir.z}

    
    local fps = lovr.timer.getFPS()

    --time = lovr.timer.getTime()-time
    lovr.graphics.print(tostring(fps), pos.x, pos.y, pos.z,1,camera.yaw-math.pi/2,0,1,0)

    --lovr.graphics.cube('line',  pos.x, pos.y+counter, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end