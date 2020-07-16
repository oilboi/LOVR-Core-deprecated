local json = require 'cjson'
local
math,lovr
=
math,lovr

local seed = lovr.math.random()
--this is the chunk generator, or map gen
--this is used by the entire game to create
--data of the map for the player to explore and such
function gen_chunk_data(x,z)
    --chunk_map[c_index] = nil
    channel:push(json.encode({x=x,z=z}))
end

--this receives the data from the thread and then pushes it 
--into the main memory of the game
function chunk_set_data(data)
    local decoded = json.decode(data)

    local hash = hash_chunk_position(decoded.x,decoded.z)

    chunk_map[hash] = {}

    for _,i in ipairs(decoded.data) do
        chunk_map[hash][i.index] = {block=i.block,light=i.light}
    end

    gpu_chunk_pool[hash] = generate_gpu_chunk(decoded.x,decoded.z)
    gpu_chunk_pool[hash]:setMaterial(atlas)
end

--this is called whenever the map is modified
--this must be moved into a buffer to be called at the end of every step
--so the map is not glitchy when a player does a bunch of updates
function chunk_update_vert(x,z)
    local c_index = hash_chunk_position(x,z)
    if gpu_chunk_pool[c_index] then
        gpu_chunk_pool[c_index] = generate_gpu_chunk(x,z) -- .mesh
        gpu_chunk_pool[c_index]:setMaterial(atlas) -- .mesh
    end
end

--this is used for the local chunk
--updating when gen_chunk is called to 
--prevent neighboring chunks from getting
--blank spots (holes) in them when the current
--chunk is being generated, this is why it is
--a 2D map of directions
local dirs = {
    {x=-1,z= 0},
    {x= 1,z= 0},
    {x= 0,z=-1},
    {x= 0,z= 1},
}

--this is the actual chunk generation call
--it is used for generating chunks at x and z in
--the 1D memory map, that's why the chunk position is
--hashed, doing 2D memory sub-indexing greatly slows
--down the game
function gen_chunk(x,z)
    local c_index = hash_chunk_position(x,z)
    --calls a chunk generation in the x and z sandbox
    gen_chunk_data(x,z)
    --this creates gpu data (meshes) for the player to actually see
    --the map
    --[[
    gpu_chunk_pool[c_index] = generate_gpu_chunk(x,z)--{mesh=generate_gpu_chunk(x,z),y=-128}--generate_gpu_chunk(x,z)--
    if gpu_chunk_pool[c_index] then
        --this sets the mesh material for the vertex map
        --to utilize, it is set to the texture atlas
        --which is extremely fast in comparison to
        --using random textures
        gpu_chunk_pool[c_index]:setMaterial(atlas) --.mesh
    end
    --here is where the neighboring chunks are updates
    --this stops holes from developing in the map as the game
    --generates chunks
    for _,dir in ipairs(dirs) do
        chunk_update_vert(x+dir.x,z+dir.z)
    end
    ]]--
end

--this is used for deleting chunks
function delete_chunk(x,z)
    local c_index = hash_chunk_position(x,z)
    gpu_chunk_pool[c_index] = nil
    chunk_map[c_index] = nil
end