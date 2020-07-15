local seed = lovr.math.random()
--this is the chunk generator, or map gen
--this is used by the entire game to create
--data of the map for the player to explore and such
function gen_chunk_data(x,z)
    local c_index = hash_chunk_position(x,z)
    local cx,cz = x,z
    chunk_map[c_index] = {}
    local x,y,z = 0,0,0
    --this is subtracting the position that the chunk roots in and then adding positional data
    --to the literal position inside of the chunk so that the noise generation follows
    --the noise generation in sync with the rest of the map
    noise = math.ceil(lovr.math.noise((x+(cx*16))/100, ((cz*16)+z)/100,seed)*100)

    for i = 1,16*16*128 do
        local index = hash_position(x,y,z)
        if y == noise then
            chunk_map[c_index][index] = 3--lovr.math.random(1,3)
        elseif y >= noise - 3 and y <= noise - 1 then
            chunk_map[c_index][index] = 1
        elseif y < noise - 3 then
            chunk_map[c_index][index] = 2
        else
            chunk_map[c_index][index] = 0
        end
        --this is using literal counting to extract the full
        --performance from luajit since the table[#table] and
        --table[table.getn(table)] operators are extremely
        --slow in comparison
        --up
        y = y + 1
        if y > 127 then
            y = 0
            --forwards
            x = x + 1
            --this must be recalculated when the position shifts 
            noise = math.ceil(lovr.math.noise((x+(cx*16))/100, ((cz*16)+z)/100,seed)*100)
            if x > 15 then
                x = 0
                --right
                --this must be recalculated when the position shifts
                noise = math.ceil(lovr.math.noise((x+(cx*16))/100, ((cz*16)+z)/100,seed)*100)
                z = z + 1
            end
        end
    end
end


--this is called whenever the map is modified
--this must be moved into a buffer to be called at the end of every step
--so the map is not glitchy when a player does a bunch of updates
function chunk_update_vert(x,z)
    local c_index = hash_chunk_position(x,z)
    if gpu_chunk_pool[c_index] then
        gpu_chunk_pool[c_index] = generate_gpu_chunk(x,z)
        gpu_chunk_pool[c_index]:setMaterial(atlas)
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
    gpu_chunk_pool[c_index] = generate_gpu_chunk(x,z)
    if gpu_chunk_pool[c_index] then
        --this sets the mesh material for the vertex map
        --to utilize, it is set to the texture atlas
        --which is extremely fast in comparison to
        --using random textures
        gpu_chunk_pool[c_index]:setMaterial(atlas)
    end
    --here is where the neighboring chunks are updates
    --this stops holes from developing in the map as the game
    --generates chunks
    for _,dir in ipairs(dirs) do
        chunk_update_vert(x+dir.x,z+dir.z)
    end
end

--this is used for deleting chunks
function delete_chunk(x,z)
    local c_index = hash_chunk_position(x,z)

    gpu_chunk_pool[c_index] = nil
    
    chunk_map[c_index] = nil
end