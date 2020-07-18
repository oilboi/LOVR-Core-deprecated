
local chunk_buffer_timer = 0
local chunk_buffer_amount = 0
local chunk_buffer = {}


function create_chunk(x,z)
    chunk_buffer_amount = chunk_buffer_amount + 1
    chunk_buffer[chunk_buffer_amount] = {x=x,z=z}
end


local function delete_chunk_buffer()
    for i = 1,chunk_buffer_amount do
        chunk_buffer[i] = chunk_buffer[i+1]
    end
    chunk_buffer[chunk_buffer_amount] = nil
    chunk_buffer_amount = chunk_buffer_amount - 1
end


function do_chunk_buffer(dt)

    if chunk_buffer_amount > 0 and chunk_buffer_timer == 0 then

        local x = chunk_buffer[1].x
        local z = chunk_buffer[1].z

        core.gen_chunk_data(x,z)
        
        chunk_buffer_timer = 0.1

        delete_chunk_buffer()

    elseif chunk_buffer_timer > 0 then
        chunk_buffer_timer = chunk_buffer_timer - dt
        if chunk_buffer_timer <= 0 then
            chunk_buffer_timer = 0
        end
    end
end


function core.load_chunks_around_player()
    local old_chunk = core.player.current_chunk
    local chunk_x = math.floor(core.player.pos.x/16)
    local chunk_z = math.floor(core.player.pos.z/16)

    if old_chunk.x ~= chunk_x then
        --local time = lovr.timer.getTime()
        local chunk_diff = chunk_x - old_chunk.x
        local direction = core.test_view_distance * chunk_diff
        for z = -core.test_view_distance+chunk_z,core.test_view_distance+chunk_z do
            create_chunk(chunk_x+direction,z)
            --core.gen_chunk(chunk_x+direction,z)
        end
        for z = -core.test_view_distance+old_chunk.z,core.test_view_distance+old_chunk.z do
            core.delete_chunk(old_chunk.x-direction,z)
        end
        core.player.current_chunk.x = chunk_x
        --temp_output = lovr.timer.getTime() - time
    end

    if old_chunk.z ~= chunk_z then
        --local time = lovr.timer.getTime()
        local chunk_diff = chunk_z - old_chunk.z
        local direction = core.test_view_distance * chunk_diff
        for x = -core.test_view_distance+chunk_x,core.test_view_distance+chunk_x do
            create_chunk(x,chunk_z+direction)
            --core.gen_chunk(x,chunk_z+direction)
        end
        for x = -core.test_view_distance+old_chunk.x,core.test_view_distance+old_chunk.x do
            core.delete_chunk(x,old_chunk.z-direction)
        end
        core.player.current_chunk.z = chunk_z
        --temp_output = lovr.timer.getTime() - time
    end
end
