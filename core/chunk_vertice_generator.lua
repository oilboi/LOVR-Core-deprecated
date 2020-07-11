-- lua locals
local
lovr,math
=
lovr,math

local chunk_size = chunksize

local max_ids = 2

local function block_check(x,y,z)
    if not memory_map[x] then
        return nil
    end
    if not memory_map[x][z] then
        return nil
    end
    return memory_map[x][z][y]
end

function generate_chunk_vertices(chunk_x,chunk_z)
    
    local chunk_stack = {}

    --height 128/8 gives 16x16x16 sized elements in the chunk stack
    for i = 0,7 do
    
    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }

    local vertex_count = 0

    local shift = 1/max_ids
    
    local index_translation = {1,  2,  3,  1,  3,  4 }

    for y = 16*i,16*(i+1)-1 do
    
    for z = chunk_z,chunk_z+15 do
    
    for x = chunk_x,chunk_x+15 do

        local data = block_check(x,y,z)

        if data > 0 then

        local translate_index = 1


        local vertice_count = 0

        local id_min = (data/max_ids)-shift
        local id_max = (data/max_ids)

        local block_pick = block_check(x,y,z-1)
        if block_pick == 0 then
            -- Face left
            chunk_vertices[#chunk_vertices+1] = { x+0, y+0,z+0, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = { x+0, y+1,z+0, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = { x+1, y+1,z+0, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = { x+1, y+0,z+0, id_max, 0} -- 1, 0


            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x,y+1,z)
        if y == 127 or block_pick == 0 then
            -- Face top
            chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+0, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+0, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_max, 0} -- 1, 0

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x+1,y,z)
        if block_pick == 0 then
            -- Face front
            chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+0, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+0, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_max, 0} -- 1, 0

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x-1,y,z)
        if block_pick == 0 then
            -- Face back
            chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+0, id_max, 0} -- 1, 0
            chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+0, id_max, 1} -- 1, 1

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x,y,z+1)
        if block_pick == 0 then
            -- Face right
            chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_max, 0} -- 1, 0
            chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_min, 0} -- 0, 0

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x,y-1,z)
        if block_pick == 0 then
            -- Face bottom
            chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+0, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+0, id_max, 0} -- 1, 0
            chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_min, 1} -- 0, 1

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        --Move onto the next block (for vertice indexing)
        vertex_count = vertex_count + vertice_count
        end
    end
    end
    end

    --local time = lovr.timer.getTime()
    if #chunk_vertices > 0 then
        -- This mesh is a cube
        chunk_stack[i] = lovr.graphics.newMesh({{ 'lovrPosition', 'int', 3 },{ 'lovrTexCoord', 'float', 2 }}, chunk_vertices, 'triangles', "static")

        --global_time_print = #chunk_stack
        chunk_stack[i]:setVertexMap(chunk_indexes)
    end

    --print(time)
    --global_time_print = lovr.timer.getTime()-time
    end
    return(chunk_stack)
end


function chunk_stack_direct_update(chunk_pool,x,y,z)
    local chunk_x = math.floor( x / 16 )
    local chunk_z = math.floor( z / 16 )
    local hash = hash_position(chunk_x,chunk_z)
    if chunk_pool[hash] then
        local tower_cube = math.floor( y / 16 )
        --if chunk_pool[hash][tower_cube] then


        local chunk_vertices = {
        }
        -- Indices to draw the faces of the cube out of triangles
        local chunk_indexes = {
        }
    
        local vertex_count = 0
    
        local shift = 1/max_ids
        
        local index_translation = {1,  2,  3,  1,  3,  4 }
    
        for y = 16*tower_cube,16*(tower_cube+1)-1 do
        
        for z = chunk_z,chunk_z+15 do
        
        for x = chunk_x,chunk_x+15 do
    
            local data = block_check(x,y,z)
    
            if data > 0 then
    
            local translate_index = 1
    
    
            local vertice_count = 0
    
            local id_min = (data/max_ids)-shift
            local id_max = (data/max_ids)
    
            local block_pick = block_check(x,y,z-1)
            if block_pick == 0 then
                -- Face left
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0,z+0, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1,z+0, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1,z+0, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0,z+0, id_max, 0} -- 1, 0
    
    
                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            end
    
            local block_pick = block_check(x,y+1,z)
            if y == 127 or block_pick == 0 then
                -- Face top
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+0, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+0, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_max, 0} -- 1, 0
    
                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            end
    
            local block_pick = block_check(x+1,y,z)
            if block_pick == 0 then
                -- Face front
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+0, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+0, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_max, 0} -- 1, 0
    
                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            end
    
            local block_pick = block_check(x-1,y,z)
            if block_pick == 0 then
                -- Face back
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+0, id_max, 0} -- 1, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+0, id_max, 1} -- 1, 1
    
                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            end
    
            local block_pick = block_check(x,y,z+1)
            if block_pick == 0 then
                -- Face right
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_max, 0} -- 1, 0
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_min, 0} -- 0, 0
    
                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            end
    
            local block_pick = block_check(x,y-1,z)
            if block_pick == 0 then
                -- Face bottom
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+0, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+0, id_max, 0} -- 1, 0
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_min, 1} -- 0, 1
    
                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            end
    
            --Move onto the next block (for vertice indexing)
            vertex_count = vertex_count + vertice_count
            end
        end
        end
        end
    
        --local time = lovr.timer.getTime()
        if #chunk_vertices > 0 then
            -- This mesh is a cube
            chunk_pool[hash][tower_cube] = lovr.graphics.newMesh({{ 'lovrPosition', 'int', 3 },{ 'lovrTexCoord', 'float', 2 }}, chunk_vertices, 'triangles', "static")
    
            --global_time_print = #chunk_stack
            chunk_pool[hash][tower_cube]:setVertexMap(chunk_indexes)
            chunk_pool[hash][tower_cube]:setMaterial(dirt)
        end
    
        --print(time)
        --global_time_print = lovr.timer.getTime()-time
        --return(chunk_stack)
        --end
    end
end