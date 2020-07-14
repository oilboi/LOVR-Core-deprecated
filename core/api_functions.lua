-- this is used to get blocks
function global_block_check(x,y,z)
    
    local chunk_x = math.floor(x/16)
    local chunk_z = math.floor(z/16)

    local relative_x = x-(chunk_x*16)
    local relative_z = z-(chunk_z*16)

   
    local hash = hash_chunk_position(chunk_x,chunk_z)

    if chunk_map[hash] then
        local index = hash_position(relative_x,y,relative_z)
        return(chunk_map[hash][index])
    end
end

-- this is used to set blocks
function set_block(x,y,z,block)
    local chunk_x = math.floor(x/16)
    local chunk_z = math.floor(z/16)

    local relative_x = x-(chunk_x*16)
    local relative_z = z-(chunk_z*16)

   
    local hash = hash_chunk_position(chunk_x,chunk_z)

    if chunk_map[hash] then
        local index = hash_position(relative_x,y,relative_z)
        chunk_map[hash][index] = block

        chunk_update_vert(chunk_x,chunk_z)
    end
end