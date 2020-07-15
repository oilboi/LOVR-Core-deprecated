temp_output = nil -- this is a debug output 

--load the libraries
lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'
require 'chunk'
require 'chunk_vertice_generator'
require 'physics'
require 'input'
require 'camera'
require 'game_math'
require 'api_functions'
require 'tick'

--this holds the data for the gpu to render
gpu_chunk_pool = {}

--this holds the chunk data for the game to work with
chunk_map = {}

--this holds the item entities for now
item_entities = {}
local item_count = 0

--this is the function which is called when the game loads
--it sets all the game setting and rendering utilities
function lovr.load()

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
        pos = {x=0,y=0,z=0},--lovr.math.vec3(0,100,-10),
        pitch = 0,
        yaw = math.pi,
        movespeed = 50
    }
    player = {
        pos = {x=0,y=80,z=0},
        speed = {x=0,y=0,z=0},
        on_ground = false,
        friction = 0.85,
        height = 1.9,
        width = 0.3,
        eye_height = 1.62,
        move_speed = 0.01,
        current_chunk = {x=0,z=0}
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

function add_item(x,y,z)
    item_count = item_count + 1

    item_entities[item_count] = {
        pos = {x=x,y=y,z=z},
        speed = {x=math.random(-1,1)*math.random()/10,y=math.random()/10,z=math.random(-1,1)*math.random()/10},
        on_ground = false,
        friction = 0.85,
        height = 0.3,
        width = 0.3,
        move_speed = 0.01,
        hover_float = 0,
        up = true
    }
end

local function do_item_physics(dt)
    for index,entity in ipairs(item_entities) do
        if entity.up then
            entity.hover_float = entity.hover_float + dt/10
            if entity.hover_float >= 0.3 then
                entity.up = false
            end
        else
            entity.hover_float = entity.hover_float - dt/10
            if entity.hover_float <= 0 then
                entity.up = true
            end
        end

        entity_aabb_physics(entity)
    end
end

local function draw_items()
    for index,entity in ipairs(item_entities) do
        lovr.graphics.cube('line', entity.pos.x, entity.pos.y+0.3+entity.hover_float, entity.pos.z, .5, lovr.timer.getTime())
    end
end


local test_view_distance = 5

local function load_chunks_around_player()
    local old_chunk = player.current_chunk

    local chunk_x = math.floor(player.pos.x/16)
    local chunk_z = math.floor(player.pos.z/16)

    if old_chunk.x ~= chunk_x then
        local chunk_diff = chunk_x - old_chunk.x
        local direction = test_view_distance * chunk_diff
        temp_output = direction
        --
        for z = -test_view_distance+chunk_z,test_view_distance+chunk_z do
            gen_chunk(chunk_x+direction,z)
        end
        for z = -test_view_distance+old_chunk.z,test_view_distance+old_chunk.z do
            delete_chunk(old_chunk.x-direction,z)
        end
        player.current_chunk.x = chunk_x
    end

    if old_chunk.z ~= chunk_z then
        local chunk_diff = chunk_z - old_chunk.z
        local direction = test_view_distance * chunk_diff
        temp_output = direction
        --
        for x = -test_view_distance+chunk_x,test_view_distance+chunk_x do
            gen_chunk(x,chunk_z+direction)
        end
        for x = -test_view_distance+old_chunk.x,test_view_distance+old_chunk.x do
            delete_chunk(x,old_chunk.z-direction)
        end
        player.current_chunk.z = chunk_z
    end
    --temp_output = tostring("currx:"..(player.current_chunk.x).."\n"..
                    --"chunkx:"..chunk_x)

end
--this is the main loop of the game [MAIN LOOP]
--this controls everything that happens "server side"
--in the game engine, right now it is being used for
--debug testing
local counter = 0
local up = true
local do_generation = true
local curr_chunk_index = {x=-test_view_distance,z=-test_view_distance}
function lovr.update(dt)
    
    load_chunks_around_player()

    tick_framerate(20)

    lovr.event.pump()

    dig()

    aabb_physics(player)

    move(dt)
    
    do_item_physics(dt)


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
        lovr.graphics.print("Items:"..item_count, -0.1, 0.062, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("+", 0, 0, -0.1, 0.01, 0, 0, 1, 0)
    lovr.graphics.pop()

    --get the camera orientation
    local x,y,z = camera.pos.x,camera.pos.y,camera.pos.z--camera.position:unpack()

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
    
    local dx,dy,dz = get_camera_dir()
    dx = dx * 4
    dy = dy * 4
    dz = dz * 4
    local pos = {x=x+dx,y=y+dy,z=z+dz}


    draw_items()
    --local fps = lovr.timer.getFPS()

    lovr.graphics.print(tostring(temp_output), pos.x, pos.y, pos.z,1,camera.yaw,0,1,0)

    --for _,data in ipairs(position_hold) do
        --lovr.graphics.print(tostring(data.x.." "..data.y.." "..data.y), data.x, data.y, data.z,0.5,camera.yaw,0,1,0)
    --end

    if selected_block then
        lovr.graphics.cube('line',  selected_block.x+0.5, selected_block.y+0.5, selected_block.z+0.5, 1)
    end

    --lovr.graphics.box(mode, x, y, z, width, height
    lovr.graphics.box("line", player.pos.x, player.pos.y+player.height/2, player.pos.z, player.width*2, player.height)
    --lovr.graphics.cube('line',  pos.x, pos.y, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end