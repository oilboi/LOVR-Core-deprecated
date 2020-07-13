-- lua locals
local
lovr,math
=
lovr,math

local chunk_size = chunksize
local max_ids = 2

--[[
function block_check(x,y,z)
    if not memory_map[x] then
        return nil
    end
    if not memory_map[x][z] then
        return nil
    end
    return memory_map[x][z][y]
end
]]--

local x_limit = 16
local z_limit = 16*128
local y_limit = 16
local function memory_position(i)
	i = i - 1
	local z = math.floor(i / z_limit)
	i = i % z_limit
	local y = math.floor(i / y_limit)
    i = i  % y_limit
	local x = math.floor(i)
	return x,y,z
end

function generate_chunk_vertices(chunk_x,chunk_z)
    -- this holds the chunk stack data
    local chunk_stack = {}
    -- The triangles which represent the
    -- chunk in gpu memory
    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }

    local vertex_count = 0

    local shift = 1/max_ids
    
    local index_translation = {1,  2,  3,  1,  3,  4 }

    for i = 1,16*16*128 do

        --local data = block_check(x,y,z)
        local data = 1

        local x,y,z = memory_position(i)

        if y > 100 then
            if x > 2 then
                data = 0
            else
                data = 2
            end
        end

        if data > 0 then

            local translate_index = 1

            local vertice_count = 0

            local id_min = (data/max_ids)-shift
            local id_max = (data/max_ids)

            --local block_pick = block_check(x,y,z-1)
            --if block_pick == 0 then
                -- Face left
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0,z+0, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1,z+0, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1,z+0, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0,z+0, id_max, 0} -- 1, 0


                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            --end

            --local block_pick = block_check(x,y+1,z)
            --if y == 127 or block_pick == 0 then
                -- Face top
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+0, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+0, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_max, 0} -- 1, 0

                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            --end

            --local block_pick = block_check(x+1,y,z)
            --if block_pick == 0 then
                -- Face front
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+0, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+0, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_max, 0} -- 1, 0

                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            --end

            --local block_pick = block_check(x-1,y,z)
            --if block_pick == 0 then
                -- Face back
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+0, id_max, 0} -- 1, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+0, id_max, 1} -- 1, 1

                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            --end

            --local block_pick = block_check(x,y,z+1)
            --if block_pick == 0 then
                -- Face right
                chunk_vertices[#chunk_vertices+1] = { x+1, y+1, z+1, id_min, 1} -- 0, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+1, z+1, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_max, 0} -- 1, 0
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_min, 0} -- 0, 0

                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            --end

            --local block_pick = block_check(x,y-1,z)
            --if block_pick == 0 then
                -- Face bottom
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+0, id_max, 1} -- 1, 1
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+0, id_max, 0} -- 1, 0
                chunk_vertices[#chunk_vertices+1] = { x+1, y+0, z+1, id_min, 0} -- 0, 0
                chunk_vertices[#chunk_vertices+1] = { x+0, y+0, z+1, id_min, 1} -- 0, 1

                for i = 1,6 do
                    chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
                end
                vertice_count = vertice_count + 4
            --end

            --Move onto the next block (for vertice indexing)
            vertex_count = vertex_count + vertice_count
        end
    end
    --end
    --end

    if #chunk_vertices > 0 then
        chunk_stack = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 }}, chunk_vertices, 'triangles', "static")
        chunk_stack:setVertexMap(chunk_indexes)
    else
        chunk_stack = nil
    end
    return(chunk_stack)
end
























































































--[[

function chunk_stack_direct_update(chunk_pool,x,y,z)

    local chunk_x = math.floor( x / 16 )

    global_time_print = chunk_x

    local chunk_z = math.floor( z / 16 )

    local hash = hash_position(chunk_x,chunk_z)

    if chunk_pool[hash] then
        local chunk_vertices = {
        }
        -- Indices to draw the faces of the cube out of triangles
        local chunk_indexes = {
        }
    
        local vertex_count = 0
    
        local shift = 1/max_ids
        
        local index_translation = {1,  2,  3,  1,  3,  4 }
    
        for y = 0,127 do
        
            for z = chunk_z*16,(chunk_z*16)+15 do
    
            for x = chunk_x*16,(chunk_x*16)+15 do
    
            local data = block_check(x,y,z)
    
            if data and data > 0 then
    
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
        
        --only produce a memory index if chunk has any data in it
        if #chunk_vertices > 0 then
            chunk_pool[hash] = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 }}, chunk_vertices, 'triangles', "static")
            chunk_pool[hash]:setVertexMap(chunk_indexes)
            chunk_pool[hash]:setMaterial(dirt)
        else
            chunk_pool[hash] = nil
        end
    end
end

]]--