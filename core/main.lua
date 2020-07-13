global_time_print = 0
chunksize = 16
gen_complete = false
selected_block = nil
collision_point = nil
local chunk_size = chunksize

lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

lovr.graphics.setDefaultFilter("nearest", 0)

require 'chunk_vertice_generator'
require 'input'
require 'camera'

--this holds the data for the gpu to render
local chunk_pool = {}

--this holds the chunk data for the game to work with
local chunk_map = {}

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
    --[[
    for i = 1,16*16*128 do
    

    local noise = math.ceil(lovr.math.noise(x/100, z/100,seed)*100)

    for y = 0,127 do

        
        if y == noise then
            memory_map[x][z][y] = 1
        elseif y < noise then
            memory_map[x][z][y] = 2
        else
            memory_map[x][z][y] = 0
        end
    end
    end
    end]]--
end


function set_block(x,y,z,block)
    if memory_map[x] and memory_map[x][z] and memory_map[x][z][y] then
        memory_map[x][z][y] = block
        chunk_stack_direct_update(chunk_pool,x,y,z)
    end
end

function chunk_update_vert(x,z)
    if chunk_pool[1] then
        chunk_pool[1] = generate_chunk_vertices(x*16,z*16)
        chunk_pool[1]:setMaterial(dirt)
    end
end


function gen_chunk(x,z)
    gen_chunk_data(x*16,z*16)
    chunk_pool[1] = generate_chunk_vertices(x*16,z*16)
    chunk_pool[1]:setMaterial(dirt)

    for xer = -1,1 do
    for zer = -1,1 do
        if math.abs(xer) + math.abs(zer) == 1 then
            chunk_update_vert(x+xer,z+zer)
        end
    end
    end
end

function lovr.load()
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)
    lovr.graphics.setBlendMode(nil,nil)
    --lovr.graphics.setWireframe(true)
    
    camera = {
        transform = lovr.math.vec3(),
        position = lovr.math.vec3(0,80,0),
        movespeed = 10,
        pitch = 0,
        yaw = 0
    }    

    dirttexture = lovr.graphics.newTexture("textures/dirt.png")

    dirt = lovr.graphics.newMaterial()
    dirt:setTexture(dirttexture)

    gen_chunk(0,0)
    --gen_chunk(0,-1)

    s_width, s_height = lovr.graphics.getDimensions()
    fov = 72
    fov_origin = fov
end

local counter = 0
local up = true
local time_delay = 0
local test_view_distance = 6
local curr_chunk_index = {x=-test_view_distance,z=-test_view_distance}
function lovr.update(dt)
    --dig()
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
    
    --[[
    if time_delay then
        time_delay = time_delay + dt
        if time_delay > 0.02 then
            time_delay = 0
            gen_chunk(curr_chunk_index.x,curr_chunk_index.z)

            curr_chunk_index.x = curr_chunk_index.x + 1
            if curr_chunk_index.x > test_view_distance then
                curr_chunk_index.x = -test_view_distance
                curr_chunk_index.z = curr_chunk_index.z + 1
                if curr_chunk_index.z > test_view_distance then
                    time_delay = nil
                end
            end
        end
    end
    ]]--
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

    for _,mesh in pairs(chunk_pool) do

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
    lovr.graphics.print(tostring(global_time_print), pos.x, pos.y, pos.z,1,camera.yaw,0,1,0)

    if selected_block then
        lovr.graphics.cube('line',  selected_block.x+0.5, selected_block.y+0.5, selected_block.z+0.5, 1)
    end
    --lovr.graphics.cube('line',  pos.x, pos.y, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end