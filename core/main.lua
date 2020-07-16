--the api table
core = {
	temp_output = nil, -- this is a debug output 
	max_ids = 4,
	entity_meshes = {},
	gpu_chunk_pool = {}, --this holds the data for the gpu to render
	chunk_map = {}, --this holds the chunk data for the game to work with
	item_entities = {}, --this holds the item entities for now
	test_view_distance = 2
}

local item_count = 0

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
require 'chunk_buffer'

local thread_code = [[
local lovr = { thread = require 'lovr.thread' }
local channel = lovr.thread.getChannel("test")
]]

--this is the function which is called when the game loads
--it sets all the game setting and rendering utilities
function lovr.load()

    channel = lovr.thread.getChannel("test")


    thread = lovr.thread.newThread(thread_code)

    thread:start()

    --these are the settings which optimize
    --the gpu utilization
    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)
    lovr.graphics.setBlendMode(nil,nil)
    lovr.graphics.setDefaultFilter("nearest", 0)
    
    lovr.graphics.setBackgroundColor(0, 191, 255, 0)

    --lovr.graphics.setWireframe(true)
    
    --this is the camera vector settings
    --used for the player to look around
    core.camera = {
        pos = {x=0,y=0,z=0},--lovr.math.vec3(0,100,-10),
        pitch = 0,
        yaw = math.pi,
        movespeed = 50
    }
    core.player = {
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
    core.atlastexture = lovr.graphics.newTexture("textures/atlas.png")
    core.atlas = lovr.graphics.newMaterial()
    core.atlas:setTexture(core.atlastexture)

    --the screen dimensions
    core.s_width, core.s_height = lovr.graphics.getDimensions()

    --the FOV settings
    core.fov = 72
    core.fov_origin = fov

    for x = -core.test_view_distance,core.test_view_distance do
    for z = -core.test_view_distance,core.test_view_distance do
        --create_chunk(x,z)
        core.gen_chunk(x,z)
    end
    end
    --this is a bit awkard here but it's required to allow
    --item entities to use the texture atlas
    for i = 1,core.max_ids do
        core.entity_meshes[i]:setMaterial(core.atlas)
    end
end


function core.add_item(x,y,z,id)
    item_count = item_count + 1

    core.item_entities[item_count] = {
        pos = {x=x,y=y,z=z},
        speed = {x=math.random(-1,1)*math.random()/10,y=math.random()/10,z=math.random(-1,1)*math.random()/10},
        id = id,
        on_ground = false,
        friction = 0.85,
        height = 0.3,
        width = 0.3,
        move_speed = 0.01,
        hover_float = 0,
        up = true,
        rotation = 0,
        timer = 0,
        physical = true,
    }
end

local function do_item_physics(dt)
    for index,entity in ipairs(core.item_entities) do
        entity.timer = entity.timer + dt
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

        entity.rotation = entity.rotation + dt
        if entity.rotation > math.pi then
            entity.rotation = entity.rotation - (math.pi*2)
        end

        core.entity_aabb_physics(entity)
    end
end

local function draw_items()
    for _,entity in ipairs(core.item_entities) do
        core.entity_meshes[entity.id]:draw(entity.pos.x, entity.pos.y+0.3+entity.hover_float, entity.pos.z, 0.3, entity.rotation, 0, 1, 0)
        --lovr.graphics.cube('line', entity.pos.x, entity.pos.y+0.3+entity.hover_float, entity.pos.z, .5, lovr.timer.getTime())
    end
end

local function delete_item(id)
    for i = id,item_count do
        core.item_entities[i] = core.item_entities[i+1]
    end
    core.item_entities[item_count] = nil
    item_count = item_count - 1
end

local function item_magnet()
    local pos = {x=core.player.pos.x,y=core.player.pos.y,z=core.player.pos.z}
    pos.y = pos.y + 0.5
    for id,entity in ipairs(core.item_entities) do
        if entity.timer >= 2 then
            local d = core.distance(pos,entity.pos)
            if d < 0.2 then
                delete_item(id)
            elseif d < 3 then
                local v = core.vec_direction(entity.pos,pos)
                v.x = v.x/3
                v.y = v.y/3
                v.z = v.z/3

                entity.speed = v
                entity.physical = false
            end
        end
        --temp_output = d
    end
end


--this is the main loop of the game [MAIN LOOP]
--this controls everything that happens "server side"
--in the game engine, right now it is being used for
--debug testing
local counter = 0
local fov_mod = 0
local up = true
function lovr.update(dt)
    core.tick_framerate(20)

    core.load_chunks_around_player()

    item_magnet()

    --lovr.event.pump()

    core.dig(dt)

    core.aabb_physics(core.player)
    
    do_item_physics(dt)

    --[[
    if up then
        fov_mod = fov_mod + dt*50
        if fov_mod >= 15 then
            up = not up
        end
    else
        fov_mod = fov_mod - dt*50
        if fov_mod <= -15 then
            up = not up
        end
    end
    fov = fov_origin + fov_mod
    ]]--
    
    --do_chunk_buffer(dt)
end

  

--this is the rendering loop
--this is what actually draws everything in the game
--engine to render and where
function lovr.draw()
    --local time = lovr.timer.getTime()
    --this is where the ui should be drawn
    lovr.graphics.push()
        lovr.graphics.print("FPS:"..lovr.timer.getFPS(), -0.1, 0.072, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("Items:"..item_count, -0.1, 0.062, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("+", 0, 0, -0.1, 0.01, 0, 0, 1, 0)
    lovr.graphics.pop()

    --get the camera orientation
    local x,y,z = core.camera.pos.x,core.camera.pos.y,core.camera.pos.z--camera.position:unpack()

    lovr.graphics.rotate(-core.camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-core.camera.yaw, 0, 1, 0)
    lovr.graphics.transform(-x,-y,-z)
    lovr.graphics.setProjection(lovr.math.mat4():perspective(0.01, 1000, 90/core.fov,core.s_width/core.s_height))

    for _,mesh in pairs(core.gpu_chunk_pool) do --data
        lovr.graphics.push()
        --if data.y < 0 then
            --data.y = data.y + 0.5
        --end
        mesh:draw()--0,data.y,0)
        lovr.graphics.pop()
    end

    lovr.graphics.push()
    
    local dx,dy,dz = core.get_camera_dir()
    dx = dx * 4
    dy = dy * 4
    dz = dz * 4
    local pos = {x=x+dx,y=y+dy,z=z+dz}


    draw_items()
    --local fps = lovr.timer.getFPS()

    --temp_output = math.floor((lovr.timer.getTime() - time)*10000)/10000
    --lovr.graphics.print(tostring(temp_output), pos.x, pos.y, pos.z,1,camera.yaw,0,1,0)

    --for _,data in ipairs(position_hold) do
        --lovr.graphics.print(tostring(data.x.." "..data.y.." "..data.y), data.x, data.y, data.z,0.5,camera.yaw,0,1,0)
    --end

    if core.selected_block then
        lovr.graphics.cube('line',  core.selected_block.x+0.5, core.selected_block.y+0.5, core.selected_block.z+0.5, 1)
    end
    --lovr.graphics.box(mode, x, y, z, width, height
    --lovr.graphics.box("line", player.pos.x, player.pos.y+player.height/2, player.pos.z, player.width*2, player.height)
    --lovr.graphics.cube('line',  pos.x, pos.y, pos.z, .5, lovr.timer.getTime())

    lovr.graphics.pop()
end
