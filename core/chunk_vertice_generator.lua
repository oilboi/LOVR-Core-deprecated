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
    local chunk = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 }, { 'lovrNormal', 'float', 3 }}, 4096*24, 'triangles')

    local chunk_vertices = {
    }
    -- Indices to draw the faces of the cube out of triangles
    local chunk_indexes = {
    }
    local vertice_count = 1
    local block_count = 0
    
    for x,datax in pairs(chunk_data) do
    for y,datay in pairs(datax) do
    for z,data in pairs(datay) do
        -- Face front
        chunk_vertices[#chunk_vertices+1] = {0,0,0, 0,0,-1}
        chunk_vertices[#chunk_vertices+1] = {0,1,0, 0,0,-1}
        chunk_vertices[#chunk_vertices+1] = {1,1,0, 0,0,-1}
        chunk_vertices[#chunk_vertices+1] = {1,0,0, 0,0,-1}

        for i = 1,6 do
            chunk_indexes[vertice_count] = index_translation[1][i]+block_count
            vertice_count = vertice_count + 1
        end
        
        -- Face top
        chunk_vertices[#chunk_vertices+1] = {1,1,0, 0,1,0}
        chunk_vertices[#chunk_vertices+1] = {0,1,0, 0,1,0}
        chunk_vertices[#chunk_vertices+1] = {0,1,1, 0,1,0}
        chunk_vertices[#chunk_vertices+1] = {1,1,1, 0,1,0}

        for i = 1,6 do
            chunk_indexes[vertice_count] = index_translation[2][i]+block_count
            vertice_count = vertice_count + 1
        end

        -- Face right
        chunk_vertices[#chunk_vertices+1] = {1,0,0, 1,0,0}
        chunk_vertices[#chunk_vertices+1] = {1,1,0, 1,0,0}
        chunk_vertices[#chunk_vertices+1] = {1,1,1, 1,0,0}
        chunk_vertices[#chunk_vertices+1] = {1,0,1, 1,0,0}

        for i = 1,6 do
            chunk_indexes[vertice_count] = index_translation[3][i]+block_count
            vertice_count = vertice_count + 1
        end

        -- Face left
        chunk_vertices[#chunk_vertices+1] = {0,0,0, -1,0,0}
        chunk_vertices[#chunk_vertices+1] = {0,0,1, -1,0,0}
        chunk_vertices[#chunk_vertices+1] = {0,1,1, -1,0,0}
        chunk_vertices[#chunk_vertices+1] = {0,1,0, -1,0,0}

        for i = 1,6 do
            chunk_indexes[vertice_count] = index_translation[4][i]+block_count
            vertice_count = vertice_count + 1
        end

        -- Face back
        chunk_vertices[#chunk_vertices+1] = {1,1,1, 0,0,1}
        chunk_vertices[#chunk_vertices+1] = {0,1,1, 0,0,1}
        chunk_vertices[#chunk_vertices+1] = {0,0,1, 0,0,1}
        chunk_vertices[#chunk_vertices+1] = {1,0,1, 0,0,1}

        for i = 1,6 do
            chunk_indexes[vertice_count] = index_translation[5][i]+block_count
            vertice_count = vertice_count + 1
        end

        -- Face bottom
        chunk_vertices[#chunk_vertices+1] = {0,0,0, 0,-1,0}
        chunk_vertices[#chunk_vertices+1] = {1,0,0, 0,-1,0}
        chunk_vertices[#chunk_vertices+1] = {1,0,1, 0,-1,0}
        chunk_vertices[#chunk_vertices+1] = {0,0,1, 0,-1,0}

        for i = 1,6 do
            chunk_indexes[vertice_count] = index_translation[6][i]+block_count
            vertice_count = vertice_count + 1
        end

        --Move onto the next block (for vertice indexing)
        block_count = block_count + 24
    end
    end
    end

    -- The cube specified above covers the space 0..1, so it's centered at (0.5, 0.5, 0.5). That's not right.
    -- Let's edit the first three coordinates of each vertex to center it at (0,0,0):
    local x = 0.5
    local y = 0.5
    local z = 0.5
    local count = 0
    for _,v in ipairs(chunk_vertices) do

    
    v[1] = v[1] - x
    v[2] = v[2] - y
    v[3] = v[3] - z

    count = count + 1

    if count == 24 then
        count = 0
        x = x + 1
        if x == 16.5 then
            x = 0.5
            y = y + 1
        end

        if y == 16.5 then
            y = 0.5
            z = z + 1
        end
        print(z)
    end
    end

    chunk:setVertices(chunk_vertices)

    chunk:setVertexMap(chunk_indexes)

    return(chunk)
end