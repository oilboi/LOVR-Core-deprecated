temp_output = nil
lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

lovr.graphics.setDefaultFilter("nearest", 0)

require 'chunk_vertice_generator'
require 'input'
require 'camera'
require 'game_math'
require 'api_functions'

--this holds the data for the gpu to render
gpu_chunk_pool = {}

--this holds the chunk data for the game to work with
chunk_map = {}

local seed = math.random()

local x_limit = 16
local z_limit = 16*128
local y_limit = 16
local function memory_position(i)
	i = i - 1
	local z = math.floor(i / z_limit)
	i = i % z_limit
	local y = math.floor(i / y_limit)
    i = i  % y_limit
	local x = math.floor(i)
	return x,y,z
end

function gen_chunk_data(x,z)
    local c_index = hash_chunk_position(x,z)
    local cx,cz = x,z
    chunk_map[c_index] = {}

    local x,y,z = 0,0,0

    for i = 1,16*16*128 do
        local index = hash_position(x,y,z)

        --local noise = math.ceil(lovr.math.noise((cx*16)+x/100,z/100, (cz*16)+z/100,seed))
        
        if y > 50 then
            chunk_map[c_index][index] = 0
        elseif y == 50 then
            chunk_map[c_index][index] = math.random(0,1)
        else
            chunk_map[c_index][index] = math.random(1,2)
        end
        
        

        --up
        y = y + 1
        if y > 127 then
            y = 0
            --forwards
            x = x + 1
            if x > 15 then
                x = 0
                --right
                z = z + 1
            end
        end
    end
end


function chunk_update_vert(x,z)
    local c_index = hash_chunk_position(x,z)
    if gpu_chunk_pool[c_index] then
        gpu_chunk_pool[c_index] = generate_chunk_vertices(x,z)
        gpu_chunk_pool[c_index]:setMaterial(dirt)
    end
end


local dirs = {
    {x=-1,z= 0},
    {x= 1,z= 0},
    {x= 0,z=-1},
    {x= 0,z= 1},
}

function gen_chunk(x,z)
    
    local c_index = hash_chunk_position(x,z)

    gen_chunk_data(x,z)

    gpu_chunk_pool[c_index] = generate_chunk_vertices(x,z)
    if gpu_chunk_pool[c_index] then
        gpu_chunk_pool[c_index]:setMaterial(dirt)
    end

    for _,dir in ipairs(dirs) do
        chunk_update_vert(x+dir.x,z+dir.z)
    end
end

local test_view_distance = 6
function lovr.load()
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)
    lovr.graphics.setBlendMode(nil,nil)
    --lovr.graphics.setWireframe(true)
    
    camera = {
        transform = lovr.math.vec3(),
        position = lovr.math.vec3(0,52,0),
        movespeed = 10,
        pitch = 0,
        yaw = math.pi
    }    

    dirttexture = lovr.graphics.newTexture("textures/dirt.png")

    dirt = lovr.graphics.newMaterial()
    dirt:setTexture(dirttexture)


    s_width, s_height = lovr.graphics.getDimensions()
    fov = 72
    fov_origin = fov
end

local counter = 0
local up = true
local time_delay = 0
local curr_chunk_index = {x=-test_view_distance,z=-test_view_distance}
function lovr.update(dt)
    dig()
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
       -- time_delay = time_delay + dt
        --if time_delay > 0.02 then
            --time_delay = 0
            gen_chunk(curr_chunk_index.x,curr_chunk_index.z)

            curr_chunk_index.x = curr_chunk_index.x + 1
            if curr_chunk_index.x > test_view_distance then
                curr_chunk_index.x = -test_view_distance
                curr_chunk_index.z = curr_chunk_index.z + 1
                if curr_chunk_index.z > test_view_distance then
                    time_delay = nil
                end
            end
        --end
    end
    --for x = -10,10 do
    --    set_block(x,127,0)
    --end
end

--local predef = chunk_size * number_of_chunks
timer = 0
function lovr.draw()
    --this is transformed from the camera rotation class
    --mat4(camera.transform):invert()
    --lovr.graphics.transform(x, y, z, sx, sy, sz, angle, ax, ay, az)
   -- local time = lovr.timer.getTime()

    local x,y,z = camera.position:unpack()

    lovr.graphics.rotate(-camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-camera.yaw, 0, 1, 0)

    lovr.graphics.transform(-x,-y,-z)

    --lovr.graphics.rotate(1 * math.pi/2, 0, 1, 0)

    lovr.graphics.setProjection(lovr.math.mat4():perspective(0.01, 1000, 90/fov,s_width/s_height))

    for _,mesh in pairs(gpu_chunk_pool) do
        lovr.graphics.push()
        mesh:draw()
        lovr.graphics.pop()
    end

    lovr.graphics.push()

    
    local dx,dy,dz = get_camera_dir()
    dx = dx * 4
    dy = dy * 4
    dz = dz * 4
    local pos = {x=x+dx,y=y+dy,z=z+dz}

    local fps = lovr.timer.getFPS()

    --time = lovr.timer.getTime()-time

    lovr.graphics.print(tostring(temp_output), pos.x, pos.y, pos.z,1,camera.yaw,0,1,0)

    if selected_block then
        lovr.graphics.cube('line',  selected_block.x+0.5, selected_block.y+0.5, selected_block.z+0.5, 1)
    end
    --lovr.graphics.cube('line',  pos.x, pos.y, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end