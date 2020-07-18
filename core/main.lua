--the api table
core = {
	temp_output = nil, -- this is a debug output 
	max_ids = 4,
	entity_meshes = {},
	gpu_chunk_pool = {}, --this holds the data for the gpu to render
	chunk_map = {}, --this holds the chunk data for the game to work with
	item_entities = {}, --this holds the item entities for now
	test_view_distance = 7
}


--load the libraries
lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'
require 'serialize'
require 'chunk'
require 'chunk_vertice_generator'
require 'physics'
require 'input'
require 'game_math'
require 'api_functions'
require 'tick'
require 'chunk_buffer'
require 'game_threads'
require 'items'


function lovr.load()

    --this is for chunk generation
    channel = lovr.thread.getChannel("chunk")
    channel2 = lovr.thread.getChannel("chunk_receive")
    thread = lovr.thread.newThread(chunk_generator_code)
    thread:start()

    --this is for chunk vertex (gpu chunks)
    channel3 = lovr.thread.getChannel("chunk_mesh")
    channel4 = lovr.thread.getChannel("chunk_mesh_receive")
    thread2 = lovr.thread.newThread(vertex_generator_code)
    thread2:start()

    lovr.mouse.setRelativeMode(true)
    lovr.graphics.setCullingEnabled(true)
    lovr.graphics.setBlendMode(nil,nil)
    lovr.graphics.setDefaultFilter("nearest", 0)
    
    lovr.graphics.setBackgroundColor(0, 191, 255, 0)

    --lovr.graphics.setWireframe(true)
    
    core.camera = {
        pos = {x=0,y=0,z=0},--lovr.math.vec3(0,100,-10),
        pitch = 0,
        yaw = math.pi,
        movespeed = 50
    }

    core.player = {
        pos = {x=0,y=100,z=0},
        speed = {x=0,y=0,z=0},
        on_ground = false,
        friction = 0.85,
        height = 1.9,
        width = 0.3,
        eye_height = 1.62,
        move_speed = 0.01,
        current_chunk = {x=0,z=0}
    }

    core.atlastexture = lovr.graphics.newTexture("textures/atlas.png")
    core.atlas = lovr.graphics.newMaterial()
    core.atlas:setTexture(core.atlastexture)

    core.s_width, core.s_height = lovr.graphics.getDimensions()

    core.fov = 72
    core.fov_origin = fov

    for x = -core.test_view_distance,core.test_view_distance do
    for z = -core.test_view_distance,core.test_view_distance do
        create_chunk(x,z)
        --core.gen_chunk(x,z)
    end
    end
    
    --this is a bit awkard here but it's required to allow
    --item entities to use the texture atlas
    for i = 1,core.max_ids do
        core.entity_meshes[i]:setMaterial(core.atlas)
    end
end


function lovr.update(dt)
    lovr.event.pump()

    --core.tick_framerate(20)

    core.load_chunks_around_player()

    item_magnet()

    core.dig(dt)

    core.aabb_physics(core.player)
    
    do_item_physics(dt)


    local message = channel2:pop(false)

    if message then
        core.chunk_set_data(message)
    end

    local message2 = channel4:pop(false)

    if message2 then
        core.render_gpu_chunk(message2)
    end

    do_chunk_buffer(dt)
end


function lovr.draw()
    --ui
    lovr.graphics.push()
        lovr.graphics.print("FPS:"..lovr.timer.getFPS(), -0.1, 0.062, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("FPS:"..lovr.timer.getFPS(), -0.1, 0.062, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("Items:"..item_count, -0.1, 0.052, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        lovr.graphics.print("Debug:"..tostring(core.temp_output), -0.1, 0.042, -0.1, 0.01, 0, 0, 1, 0,0, "left","top")
        
        lovr.graphics.print("+", 0, 0, -0.1, 0.01, 0, 0, 1, 0)
    lovr.graphics.pop()

    --camera orientation
    local x,y,z = core.camera.pos.x,core.camera.pos.y,core.camera.pos.z--camera.position:unpack()

    lovr.graphics.rotate(-core.camera.pitch, 1, 0, 0)
    lovr.graphics.rotate(-core.camera.yaw, 0, 1, 0)
    lovr.graphics.transform(-x,-y,-z)

    --lovr.graphics.setProjection(lovr.math.mat4():perspective(0.01, 1000, 90/core.fov,core.s_width/core.s_height))
	
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
