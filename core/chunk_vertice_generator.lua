-- lua locals
local
lovr
=
lovr

local max_ids = max_ids --this is a temporary placeholder for the 2D texture atlas

local index_translation = {1,  2,  3,  1,  3,  4 }
--[[ This is special documentation because it is quite hard to explain

The reason that this function manually counts up in the "vertex_count" and

"index_count" is because it is extremely fast to do this in the cpu directly

the way that LuaJIT likes to handle cpu and memory instances. This was using

index_count[#index_count + 1] before hand and this creates a table.getn()

procedure per table index, no matter how big the table gets, slowing it down

severely. Same with vertex_count. Utilizing the raw performance of the cpu

to manually integer count this up (+1) allows for chunks to generate almost 

instantly.


The "adjuster_x" and "adjuster_z" are multipliers of the 2D chunk X and Z

positions (x16) to correcly distribute this into memory easily.

This data is then fed into "lovr.graphics.newMesh" along with

"setVertexMap" to actually create the memory instance in openGL.
]]--


--this creates meshes for the gpu to draw
function generate_gpu_chunk(chunk_x,chunk_z)

    --this is pulling the memory directly out of the global
    --1D chunk data map
    local c_index = hash_chunk_position(chunk_x,chunk_z)
    local chunk_data = chunk_map[c_index]

    -- The triangles which represent the
    -- chunk in gpu memory
    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }

    --these are the counts used for adjusting the vertex
    --map and vertex count, it's extremely important
    --that these are left at 0
    local index_count = 0
    local vertex_count = 0

    local shift = 1/max_ids

    local x,y,z = 0,0,0

    --this needs to be included to incorperate the literal
    --position in memory and in game
    local adjuster_x = chunk_x*16
    local adjuster_z = chunk_z*16

    --this is 1 through the max chunk size in a 1D memory map,
    --which is 65,536. This is why each index is hashed to utilize
    --the raw performance of the cpu with a better memory handling
    --to provide extreme performance.
    for i = 1,16*16*128 do

        --hash position and get data
        local index = hash_position(x,y,z)
        data = chunk_data[index]

        if data and data > 0 then

            --this moves the pointer of the beginning and ending of
            --the texture atlas, this is only 2D for now so only the
            --X axis is being utilized
            local id_min = (data/max_ids)-shift
            local id_max = (data/max_ids)


            --yes, this was extremely tedious to program

            local block_pick = get_block(adjuster_x+x+1,y,adjuster_z+z)
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

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_min, 0, 0, 0, -1} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_min, 1, 0, 0, -1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_max, 1, 0, 0, -1} -- 1, 1

                vertex_count = vertex_count + 1
                
                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_max, 0, 0, 0, -1} -- 1, 0

            end

            local block_pick = get_block(adjuster_x+x,y+1,adjuster_z+z)
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

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_min, 0, 0, 1, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_min, 1, 0, 1, 0} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_max, 1, 0, 1, 0} -- 1, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_max, 0, 0, 1, 0} -- 1, 0
                
            end


            local block_pick = get_block(adjuster_x+x,y,adjuster_z+z+1)
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

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_min, 1, 1, 0, 0} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_max, 1, 1, 0, 0} -- 1, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_max, 0, 1, 0, 0} -- 1, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_min, 0, 1, 0, 0} -- 0, 0

            end

            local block_pick = get_block(adjuster_x+x,y,adjuster_z+z-1)
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

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0,z+0+adjuster_z, id_min, 0, -1, 0, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1,z+0+adjuster_z, id_min, 1, -1, 0, 0} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1,z+0+adjuster_z, id_max, 1, -1, 0, 0} -- 1, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0,z+0+adjuster_z, id_max, 0, -1, 0, 0} -- 1, 0
            end

            local block_pick = get_block(adjuster_x+x-1,y,adjuster_z+z)
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

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_max, 0, 0, 0, 1} -- 1, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_min, 0, 0, 0, 1} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_min, 1, 0, 0, 1} -- 0, 1

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_max, 1, 0, 0, 1} -- 1, 1
            end

            

            local block_pick = get_block(adjuster_x+x,y-1,adjuster_z+z)
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

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_max, 1, 0, -1, 0} -- 1, 1

                vertex_count = vertex_count + 1
                
                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_max, 0, 0, -1, 0} -- 1, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_min, 0, 0, -1, 0} -- 0, 0

                vertex_count = vertex_count + 1

                chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_min, 1, 0, -1, 0} -- 0, 1
            
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
 
    -- this holds the gpu chunk mesh data
    local gpu_chunk
    if #chunk_vertices > 0 then
        --set the data
        gpu_chunk = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 }, { 'lovrNormal', 'float', 3 }}, chunk_vertices, 'triangles', "static")
        gpu_chunk:setVertexMap(chunk_indexes)
    else
        gpu_chunk = nil
    end

    --return the data to the function
    return(gpu_chunk)
end


for id = 1,max_ids do
    -- The triangles which represent the
    -- chunk in gpu memory
    local item_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local item_indexes = {
    }

    --these are the counts used for adjusting the vertex
    --map and vertex count, it's extremely important
    --that these are left at 0
    local index_count = 0
    local vertex_count = 0

    local shift = 1/max_ids


    --this moves the pointer of the beginning and ending of
    --the texture atlas, this is only 2D for now so only the
    --X axis is being utilized
    local id_min = (id/max_ids)-shift
    local id_max = (id/max_ids)

    -- Face left
    
    --vertex map
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[1]+vertex_count
    
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[2]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[3]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[4]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[5]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[6]+vertex_count

    
    --tris
    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 0, id_min, 0} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1,0, id_min, 1} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 0, id_max, 1} -- 1, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 0, id_max, 0} -- 1, 0


    -- Face top
    
    --vertex map
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[1]+vertex_count
    
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[2]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[3]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[4]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[5]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[6]+vertex_count
    

    --tris
    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 0, id_min, 0} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 0, id_min, 1} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 1, id_max, 1} -- 1, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 1, id_max, 0} -- 1, 0
    

    -- Face front
    
    --vertex map
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[1]+vertex_count
    
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[2]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[3]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[4]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[5]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[6]+vertex_count


    --tris
    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 0, id_min, 0} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 0, id_min, 1} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 1, id_max, 1} -- 1, 1

    vertex_count = vertex_count + 1
    
    item_vertices[vertex_count] = { 1, 0, 1, id_max, 0} -- 1, 0


    -- Face back
    
    --vertex map
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[1]+vertex_count
    
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[2]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[3]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[4]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[5]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[6]+vertex_count

    --tris
    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 0, id_max, 0} -- 1, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 1, id_min, 0} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 1, id_min, 1} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 0, id_max, 1} -- 1, 1

    -- Face right

    --vertex map                
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[1]+vertex_count
    
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[2]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[3]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[4]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[5]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[6]+vertex_count

    --tris
    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 1, id_min, 1} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 1, id_max, 1} -- 1, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 1, id_max, 0} -- 1, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 1, id_min, 0} -- 0, 0


    -- Face bottom
    
    --vertex map                
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[1]+vertex_count
    
    index_count = index_count + 1
    item_indexes[index_count] = index_translation[2]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[3]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[4]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[5]+vertex_count

    index_count = index_count + 1
    item_indexes[index_count] = index_translation[6]+vertex_count

    --tris
    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 0, id_max, 1} -- 1, 1

    vertex_count = vertex_count + 1
    
    item_vertices[vertex_count] = { 1, 0, 0, id_max, 0} -- 1, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 1, id_min, 0} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 1, id_min, 1} -- 0, 1
 
    --this is a quick hack to fix the offset because I don't
    --want to go through all the vertices right now
    for i = 1,vertex_count do
        for z = 1,3 do
            item_vertices[i][z] = item_vertices[i][z] - 0.5
        end
    end

    --set the data
    entity_meshes[id] = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 }}, item_vertices, 'triangles', "static")
    entity_meshes[id]:setVertexMap(item_indexes)
end
