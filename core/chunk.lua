local json = require 'cjson'
local math,lovr = math,lovr


function core.gen_chunk_data(x,z)
    channel:push(json.encode({x=x,z=z}),false)
end


function core.chunk_set_data(data)
    --local time = lovr.timer.getTime()
    --core.temp_output = lovr.timer.getTime() - time
    local time = lovr.timer.getTime()
    
    local decoded = json.decode(data)

    core.temp_output = lovr.timer.getTime() - time
    
    local hash = core.hash_chunk_position(decoded.x,decoded.z)
    
    core.chunk_map[hash] = {}
    
    for _,i in ipairs(decoded.data) do
        core.chunk_map[hash][i.index] = {block=i.block,light=i.light}
    end
    core.generate_gpu_chunk(decoded.x,decoded.z)
end


function core.chunk_update_vert(x,z)
    local c_index = core.hash_chunk_position(x,z)
    if core.gpu_chunk_pool[c_index] then
        core.generate_gpu_chunk(x,z)
    end
end


local dirs = {
    {x=-1,z= 0},
    {x= 1,z= 0},
    {x= 0,z=-1},
    {x= 0,z= 1},
}
function core.gen_chunk(x,z)
    local c_index = core.hash_chunk_position(x,z)
    core.gen_chunk_data(x,z)

    --for _,dir in ipairs(dirs) do
        --core.chunk_update_vert(x+dir.x,z+dir.z)
    --end
    
end


function core.delete_chunk(x,z)
    local c_index = core.hash_chunk_position(x,z)
    core.gpu_chunk_pool[c_index] = nil
    core.chunk_map[c_index] = nil
end
