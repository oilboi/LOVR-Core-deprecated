-- lua locals
local
ipairs,lovr,math
=
ipairs,lovr,math

local chunk_size = chunksize

local max_ids = 2

function generate_chunk_vertices()
    local time = lovr.timer.getTime()
    
    local chunk_data = {}
    for x = 1,chunk_size do
    chunk_data[x] = {}
    for y = 1,chunk_size do
    chunk_data[x][y] = {}
    for z = 1,chunk_size do
    chunk_data[x][y][z] = lovr.math.random(1,2)
    end
    end
    end

    local function block_check(x,y,z)
        if not chunk_data[x] then
            return nil
        end
        if not chunk_data[x][y] then
            return nil
        end
        --if not chunk_data[x][y][z] then
        --    return nil
        --end
        return chunk_data[x][y][z]
    end
    
    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }

    local vertex_count = 0

    local shift = 1/max_ids
    
    local index_translation = {1,  2,  3,  1,  3,  4 }

    for x,datax in ipairs(chunk_data) do
    for y,datay in ipairs(datax) do
    for z,data  in ipairs(datay) do
        
        if data > 0 then

        local translate_index = 1


        local vertice_count = 0

        local id_min = (data/max_ids)-shift
        local id_max = (data/max_ids)

        local block_pick = block_check(x,y,z-1)
        if not block_pick or block_pick == 0 then
            -- Face left
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+0-0.5, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+0-0.5, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+0-0.5, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+0-0.5, id_max, 0} -- 1, 0


            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x,y+1,z)
        if not block_pick or block_pick == 0 then
            -- Face top
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+0-0.5, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+0-0.5, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+1-0.5, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+1-0.5, id_max, 0} -- 1, 0

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x+1,y,z)
        if not block_pick or block_pick == 0 then
            -- Face front
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+0-0.5, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+0-0.5, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+1-0.5, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+1-0.5, id_max, 0} -- 1, 0

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x-1,y,z)
        if not block_pick or block_pick == 0 then
            -- Face back
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+0-0.5, id_max, 0} -- 1, 0
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+1-0.5, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+1-0.5, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+0-0.5, id_max, 1} -- 1, 1

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x,y,z+1)
        if not block_pick or block_pick == 0 then
            -- Face right
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+1-0.5, id_min, 1} -- 0, 1
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+1-0.5, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+1-0.5, id_max, 0} -- 1, 0
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+1-0.5, id_min, 0} -- 0, 0

            for i = 1,6 do
                chunk_indexes[#chunk_indexes+1] = index_translation[i]+vertex_count+vertice_count
            end
            vertice_count = vertice_count + 4
        end

        local block_pick = block_check(x,y-1,z)
        if not block_pick or block_pick == 0 then
            -- Face bottom
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+0-0.5, id_max, 1} -- 1, 1
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+0-0.5, id_max, 0} -- 1, 0
            chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+1-0.5, id_min, 0} -- 0, 0
            chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+1-0.5, id_min, 1} -- 0, 1

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
    

    -- This mesh is a cube
    local chunk = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 }}, chunk_vertices, 'triangles', "static")

    chunk:setVertexMap(chunk_indexes)

    
    time = lovr.timer.getTime()-time
    --print(time)
    

    return(chunk)
end