-- lua locals
local lovr = lovr
local ffi = require('ffi')
local max_ids = core.max_ids
local index_translation = {1,  2,  3,  1,  3,  4 }


function core.generate_gpu_chunk(chunk_x,chunk_z)
    --local time = lovr.timer.getTime()
    --going to have to stream this to the other chunk
    local x = (chunk_x * 16)-- - 1
    local y = 0
    local z = (chunk_z * 16)-- - 1

    local x_origin = x
    --the real position in the chunk
    local rx = 0
    local ry = 0
    local rz = 0

    local gotten_block
    local count = 0
    
    local hash = core.hash_chunk_position(chunk_x,chunk_z)

    local temp_map = core.chunk_map[hash]

    --(chunk size * double byte usage * data) + usage for chunk_x and chunk_z
    local blob = lovr.data.newBlob((16*16*128*9*3)+3)

    local array = ffi.cast("double*", blob:getPointer())

    for i = 1,16*16*128 do

        count = count + 1
        array[count] = core.hash_position(rx,ry,rz)

        count = count + 1
        array[count] = core.get_block(x,y,z)

        count = count + 1
        array[count] = 15

        --up
        y  = y  + 1
        ry = ry + 1
        if y > 127 then
            y  = 0
            ry = 0
            --forwards
            x  = x  + 1
            rx = rx + 1
            if rx > 15 then
                x  = x_origin
                rx = 0
                --right
                z  = z  + 1
                rz = rz + 1
            end
        end
    end

    array[0] = count

    count = count + 1
    array[count] = chunk_x
    count = count + 1
    array[count] = chunk_z
    
    --core.temp_output = lovr.timer.getTime() - time
    
    channel3:push(blob, false)

end


function core.render_gpu_chunk(data)
    --local time = lovr.timer.getTime()

    local array = ffi.cast("double*", data:getPointer())


    local vertex_count = array[0]
    local table_goal = vertex_count/12

    local real_count = 0

    local table_count = 0

    local chunk_vertices = {}

    while table_count < table_goal do
        table_count = table_count + 1
        chunk_vertices[table_count] = {}
        local temp_table = chunk_vertices[table_count]
        for i = 1,12 do
            real_count = real_count + 1
            temp_table[i] = array[real_count]
        end
    end
    
    real_count = real_count + 1
    local index_count = array[real_count]

    local chunk_indexes = {}

    count = 0

    while count < index_count do
        count = count + 1
        real_count = real_count + 1
        chunk_indexes[count] = array[real_count]
    end

    real_count = real_count + 1
    local chunk_x = array[real_count]
    real_count = real_count + 1
    local chunk_z = array[real_count]


    print("----------",chunk_x,chunk_z)
    print("other_v:"..vertex_count)

    print("v_tables: "..vertex_count/12)

    print("other_i:"..index_count)

    local hash = core.hash_chunk_position(chunk_x,chunk_z)

    --set the data
    core.gpu_chunk_pool[hash] = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 },{ 'lovrNormal', 'float', 3 },{'lovrVertexColor', 'float', 4}}, chunk_vertices, 'triangles', "static")
    core.gpu_chunk_pool[hash]:setVertexMap(chunk_indexes)
    core.gpu_chunk_pool[hash]:setMaterial(core.atlas)
    --core.temp_output = lovr.timer.getTime() - time
end

--item mesh
for id = 1,max_ids do
    local item_vertices = {
    }

    local item_indexes = {
    }

    --LEAVE THESE AT 0
    local index_count = 0
    local vertex_count = 0

    local shift = 1/max_ids

    local id_min = (id/max_ids)-shift
    local id_max = (id/max_ids)

    local light = math.random()
    local r,g,b,a = light,light,light,1

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

    item_vertices[vertex_count] = { 0, 0, 0, id_min, 0, 0, 0,-1, r,g,b,a} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 0, id_min, 1, 0, 0,-1, r,g,b,a} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 0, id_max, 1, 0, 0,-1, r,g,b,a} -- 1, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 0, id_max, 0, 0, 0,-1, r,g,b,a} -- 1, 0

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

    item_vertices[vertex_count] = { 1, 1, 0, id_min, 0, 0, 1, 0, r,g,b,a} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 0, id_min, 1, 0, 1, 0, r,g,b,a} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 1, id_max, 1, 0, 1, 0, r,g,b,a} -- 1, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 1, id_max, 0, 0, 1, 0, r,g,b,a} -- 1, 0

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

    item_vertices[vertex_count] = { 1, 0, 0, id_min, 0, 1, 0, 0, r,g,b,a} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 0, id_min, 1, 1, 0, 0, r,g,b,a} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 1, 1, id_max, 1, 1, 0, 0, r,g,b,a} -- 1, 1

    vertex_count = vertex_count + 1
    
    item_vertices[vertex_count] = { 1, 0, 1, id_max, 0, 1, 0, 0, r,g,b,a} -- 1, 0

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

    item_vertices[vertex_count] = { 0, 0, 0, id_max, 0,-1, 0, 0, r,g,b,a} -- 1, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 1, id_min, 0,-1, 0, 0, r,g,b,a} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 1, id_min, 1,-1, 0, 0, r,g,b,a} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 0, id_max, 1,-1, 0, 0, r,g,b,a} -- 1, 1

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

    item_vertices[vertex_count] = { 1, 1, 1, id_min, 1, 0, 0, 1, r,g,b,a} -- 0, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 1, 1, id_max, 1, 0, 0, 1, r,g,b,a} -- 1, 1

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 1, id_max, 0, 0, 0, 1, r,g,b,a} -- 1, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 1, id_min, 0, 0, 0, 1, r,g,b,a} -- 0, 0

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

    item_vertices[vertex_count] = { 0, 0, 0, id_max, 1, 0,-1, 0, r,g,b,a} -- 1, 1

    vertex_count = vertex_count + 1
    
    item_vertices[vertex_count] = { 1, 0, 0, id_max, 0, 0,-1, 0, r,g,b,a} -- 1, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 1, 0, 1, id_min, 0, 0,-1, 0, r,g,b,a} -- 0, 0

    vertex_count = vertex_count + 1

    item_vertices[vertex_count] = { 0, 0, 1, id_min, 1, 0,-1, 0, r,g,b,a} -- 0, 1
 
    for i = 1,vertex_count do
        for z = 1,3 do
            item_vertices[i][z] = item_vertices[i][z] - 0.5
        end
    end

    core.entity_meshes[id] = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 },{ 'lovrTexCoord', 'float', 2 },{ 'lovrNormal', 'float', 3 },{'lovrVertexColor', 'float', 4}}, item_vertices, 'triangles', "static")
    core.entity_meshes[id]:setVertexMap(item_indexes)
end
