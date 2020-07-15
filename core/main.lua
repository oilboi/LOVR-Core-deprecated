temp_output = nil -- this is a debug output 

--load the libraries
lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'
require 'chunk'
require 'chunk_vertice_generator'
require 'input'
require 'camera'
require 'game_math'
require 'api_functions'

--this holds the data for the gpu to render
gpu_chunk_pool = {}

--this holds the chunk data for the game to work with
chunk_map = {}

--this is the function which is called when the game loads
--it sets all the game setting and rendering utilities
function lovr.load()

    world = lovr.physics.newWorld(0, -10, 0, true, nil)
    
    --these are the settings which optimize
    --the gpu utilization
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)
    lovr.graphics.setBlendMode(nil,nil)
    lovr.graphics.setDefaultFilter("nearest", 0)

    --lovr.graphics.setWireframe(true)
    
    --this is the camera vector settings
    --used for the player to look around
    camera = {
        transform = lovr.math.vec3(),
        position = lovr.math.vec3(0,130,0),
        movespeed = 10,
        pitch = 0,
        yaw = math.pi
    }    

    --this is the texture atlas, this is created as a texture
    --then set to a material to utilize the default blend mode
    atlastexture = lovr.graphics.newTexture("textures/atlas.png")
    atlas = lovr.graphics.newMaterial()
    atlas:setTexture(atlastexture)

    --the screen dimensions
    s_width, s_height = lovr.graphics.getDimensions()

    --the FOV settings
    fov = 72
    fov_origin = fov
end


--this is the main loop of the game [MAIN LOOP]
--this controls everything that happens "server side"
--in the game engine, right now it is being used for
--debug testing
local counter = 0
local up = true
local do_generation = true
local test_view_distance = 5
local curr_chunk_index = {x=-test_view_distance,z=-test_view_distance}
function lovr.update(dt)
    lovr.event.pump()
    dig()
    move(dt)

    --[[ --this is debug
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
    ]]--
    
    if do_generation then
        gen_chunk(curr_chunk_index.x,curr_chunk_index.z)

        curr_chunk_index.x = curr_chunk_index.x + 1
        if curr_chunk_index.x > test_view_distance then
            curr_chunk_index.x = -test_view_distance
            curr_chunk_index.z = curr_chunk_index.z + 1
            if curr_chunk_index.z > test_view_distance then
                do_generation = nil
            end
        end
    end
end


--this is the rendering loop
--this is what actually draws everything in the game
--engine to render and where
function lovr.draw()
    --this is where the ui should be drawn
    lovr.graphics.push()
        lovr.graphics.print("FPS:"..lovr.timer.getFPS(), -0.1, 0.072, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("+", 0, 0, -0.1, 0.01, 0, 0, 1, 0)
    lovr.graphics.pop()

    --get the camera orientation
    local x,y,z = camera.position:unpack()

    lovr.graphics.rotate(-camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-camera.yaw, 0, 1, 0)
    lovr.graphics.transform(-x,-y,-z)
    lovr.graphics.setProjection(lovr.math.mat4():perspective(0.01, 1000, 90/fov,s_width/s_height))

    for _,mesh in pairs(gpu_chunk_pool) do
        lovr.graphics.push()
        mesh:draw()
        lovr.graphics.pop()
    end

    lovr.graphics.push()

    
    --local dx,dy,dz = get_camera_dir()
    --dx = dx * 4
    --dy = dy * 4
    --dz = dz * 4
    --local pos = {x=x+dx,y=y+dy,z=z+dz}

    --local fps = lovr.timer.getFPS()

    --lovr.graphics.print(tostring(temp_output), pos.x, pos.y, pos.z,1,camera.yaw,0,1,0)

    --for _,data in ipairs(position_hold) do
        --lovr.graphics.print(tostring(data.x.." "..data.y.." "..data.y), data.x, data.y, data.z,0.5,camera.yaw,0,1,0)
    --end

    if selected_block then
        lovr.graphics.cube('line',  selected_block.x+0.5, selected_block.y+0.5, selected_block.z+0.5, 1)
    end
    --lovr.graphics.cube('line',  pos.x, pos.y, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end