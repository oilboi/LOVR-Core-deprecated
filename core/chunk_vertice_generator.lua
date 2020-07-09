local chunk_data = {}
for x = 1,16 do
chunk_data[x] = {}
for y = 1,16 do
chunk_data[x][y] = {}
for z = 1,16 do
chunk_data[x][y][z] = lovr.math.random(0,1)
end
end
end

local index_translation = {
    {1,  2,  3,  1,  3,  4 },  -- Face front
    {5,  6,  7,  5,  7,  8 },  -- Face top
    {9,  10, 11, 9,  11, 12}, -- Face right
    {13, 14, 15, 13, 15, 16}, -- Face left
    {17, 18, 19, 17, 19, 20}, -- Face back
    {21, 22, 23, 21, 23, 24}, -- Face bottom
}

function generate_chunk_vertices()
    -- This mesh is a cube
    local chunk = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 }, { 'lovrNormal', 'float', 3 }}, 4096*24, 'triangles') --(4096 is 16*16*16 can be replaced with chunk size)

    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }
    local block_count = 0
    
    for x,datax in pairs(chunk_data) do
    for y,datay in pairs(datax) do
    for z,data in pairs(datay) do        
        if data > 0 then
        -- Face front
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+0-0.5, 0,0,-1,lovr.math.newVec3(0,0,0),lovr.math.newVec2(16, 16)}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+0-0.5, 0,0,-1,lovr.math.newVec3(0,0,0),lovr.math.newVec2(16, 16)}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+0-0.5, 0,0,-1,lovr.math.newVec3(0,0,0),lovr.math.newVec2(16, 16)}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+0-0.5, 0,0,-1,lovr.math.newVec3(0,0,0),lovr.math.newVec2(16, 16)}

        for i = 1,6 do
            chunk_indexes[#chunk_indexes+1] = index_translation[1][i]+block_count
        end
        
        -- Face top
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+0-0.5, 0,1,0}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+0-0.5, 0,1,0}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+1-0.5, 0,1,0}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+1-0.5, 0,1,0}

        for i = 1,6 do
            chunk_indexes[#chunk_indexes+1] = index_translation[2][i]+block_count
        end

        -- Face right
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+0-0.5, 1,0,0}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+0-0.5, 1,0,0}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+1-0.5, 1,0,0}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+1-0.5, 1,0,0}

        for i = 1,6 do
            chunk_indexes[#chunk_indexes+1] = index_translation[3][i]+block_count
        end

        -- Face left
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+0-0.5, -1,0,0}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+1-0.5, -1,0,0}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+1-0.5, -1,0,0}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+0-0.5, -1,0,0}

        for i = 1,6 do
            chunk_indexes[#chunk_indexes+1] = index_translation[4][i]+block_count
        end

        -- Face back
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+1-0.5,z+1-0.5, 0,0,1}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+1-0.5,z+1-0.5, 0,0,1}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+1-0.5, 0,0,1}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+1-0.5, 0,0,1}

        for i = 1,6 do
            chunk_indexes[#chunk_indexes+1] = index_translation[5][i]+block_count
        end

        -- Face bottom
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+0-0.5, 0,-1,0}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+0-0.5, 0,-1,0}
        chunk_vertices[#chunk_vertices+1] = {x+1-0.5,y+0-0.5,z+1-0.5, 0,-1,0}
        chunk_vertices[#chunk_vertices+1] = {x+0-0.5,y+0-0.5,z+1-0.5, 0,-1,0}

        for i = 1,6 do
            chunk_indexes[#chunk_indexes+1] = index_translation[6][i]+block_count
        end

        --Move onto the next block (for vertice indexing)
        block_count = block_count + 24
        end
    end
    end
    end

    chunk:setVertices(chunk_vertices)

    chunk:setVertexMap(chunk_indexes)

    return(chunk)
end