-- lua locals
local
lovr
=
lovr

local chunk_size = chunksize
local max_ids = 2


local function block_check(x,y,z)
    local index = hash_position(x,y,z)
    return(chunk_data[index])
end

local x_limit = 16
local z_limit = 16*128
local y_limit = 16

function generate_chunk_vertices(chunk_x,chunk_z)

    local c_index = hash_chunk_position(chunk_x,chunk_z)

    local chunk_data = chunk_map[c_index]

    -- The triangles which represent the
    -- chunk in gpu memory
    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }

    local index_count = 0

    local vertex_count = 0

    local shift = 1/max_ids
    
    local index_translation = {1,  2,  3,  1,  3,  4 }

    local x,y,z = 0,0,0

    --this needs to be included to incorperate the literal
    --position in memory and in game
    local adjuster_x = chunk_x*16
    local adjuster_z = chunk_z*16

    for i = 1,16*16*128 do

        local index = hash_position(x,y,z)

        data = chunk_data[index]

        if data and data > 0 then

            local id_min = (data/max_ids)-shift
            local id_max = (data/max_ids)

            local block_pick = global_block_check(adjuster_x+x,y,adjuster_z+z-1)
            if block_pick == 0 then
                -- Face left
                
                --vertex map
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[1]+vertex_count
                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[2]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[3]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[4]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[5]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[6]+vertex_count

                
                --tris
                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0,z+0+adjuster_z, id_min, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1,z+0+adjuster_z, id_min, 1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1,z+0+adjuster_z, id_max, 1} -- 1, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0,z+0+adjuster_z, id_max, 0} -- 1, 0
            end
            
            local block_pick = global_block_check(adjuster_x+x,y+1,adjuster_z+z)
            if y == 127 or block_pick == 0 then
                -- Face top
                
                --vertex map
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[1]+vertex_count
                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[2]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[3]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[4]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[5]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[6]+vertex_count
                

                --tris
                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_min, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_min, 1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_max, 1} -- 1, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_max, 0} -- 1, 0
                
            end

            local block_pick = global_block_check(adjuster_x+x+1,y,adjuster_z+z)
            if block_pick == 0 then
                -- Face front
                
                --vertex map
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[1]+vertex_count
                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[2]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[3]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[4]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[5]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[6]+vertex_count


                --tris
                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_min, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_min, 1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_max, 1} -- 1, 1

                vertex_count = vertex_count + 1
                
                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_max, 0} -- 1, 0

            end

            local block_pick = global_block_check(adjuster_x+x-1,y,adjuster_z+z)
            if block_pick == 0 then
                -- Face back
                
                --vertex map
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[1]+vertex_count
                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[2]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[3]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[4]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[5]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[6]+vertex_count

                --tris
                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_max, 0} -- 1, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_min, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_min, 1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_max, 1} -- 1, 1
            end

            local block_pick = global_block_check(adjuster_x+x,y,adjuster_z+z+1)
            if block_pick == 0 then
                -- Face right

                --vertex map                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[1]+vertex_count
                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[2]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[3]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[4]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[5]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[6]+vertex_count

                --tris
                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_min, 1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_max, 1} -- 1, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_max, 0} -- 1, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_min, 0} -- 0, 0

            end

            local block_pick = global_block_check(adjuster_x+x,y-1,adjuster_z+z)
            if y > 0 and block_pick == 0 then
                -- Face bottom
                
                --vertex map                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[1]+vertex_count
                
                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[2]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[3]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[4]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[5]+vertex_count

                index_count = index_count + 1
                chunk_indexes[index_count] = index_translation[6]+vertex_count

                --tris
                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_max, 1} -- 1, 1

                vertex_count = vertex_count + 1
                
                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_max, 0} -- 1, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_min, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_min, 1} -- 0, 1
            
            end
            
        end

        --up
        y = y + 1
        if y > 127 then
            y = 0
            --forwards
            x = x + 1
            if x > 15 then
                x = 0
                --right
                z = z + 1
            end
        end
    end
    
    --global_time_print = lovr.timer.getTime() - time


    --local time = lovr.timer.getTime()

    -- this holds the chunk stack data
    local gpu_chunk
    if #chunk_vertices > 0 then
        gpu_chunk = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 }}, chunk_vertices, 'triangles', "static")
        gpu_chunk:setVertexMap(chunk_indexes)
    else
        gpu_chunk = nil
    end
    --global_time_print = lovr.timer.getTime() - time

    return(gpu_chunk)
end
