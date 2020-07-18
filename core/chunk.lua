local ffi = require('ffi')

function core.gen_chunk_data(x,z)

    local time = lovr.timer.getTime()

    local blob = lovr.data.newBlob(3*8)

    local array = ffi.cast("double*", blob:getPointer())

    array[1] = x
    array[2] = z
   
    channel:push(blob,false)
end


function core.chunk_set_data(data)
    --local time = lovr.timer.getTime()
    --core.temp_output = lovr.timer.getTime() - time
    --local time = lovr.timer.getTime()
    local array = ffi.cast("double*", data:getPointer())   
    local i_count = array[0]
    local count = 0

    local hash = core.hash_chunk_position(array[i_count+1],array[i_count+2])
    core.chunk_map[hash] = {}

    local chunk = core.chunk_map[hash]

    while count < i_count do
        
        count = count + 1
        
        chunk[array[count]] = {}

        local block_index = chunk[array[count]]

        count = count + 1
        block_index.block = array[count]

        count = count + 1
        block_index.light = array[count]
    end
    
    --[[
    core.chunk_map[hash] = {}
    
    for _,i in ipairs(decoded.data) do
        core.chunk_map[hash][i.index] = {block=i.block,light=i.light}
    end
    ]]--
    core.generate_gpu_chunk(array[i_count+1],array[i_count+2])
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
