chunk_generator_code = [[
local lovr = { thread = require 'lovr.thread', math = require 'lovr.math', data = require 'lovr.data' }
local ffi = require('ffi')
local channel = lovr.thread.getChannel("chunk")
local channel2 = lovr.thread.getChannel("chunk_receive")
local seed = lovr.math.random()

--this is the calculator for hashing positions in the 1D memory
--of the chunk sanbox
function hash_position(x,y,z)
	return (z + 64) * 128 * 128
		 + (y + 64) * 128
		 + (x + 64)
end

local message

local blob = lovr.data.newBlob((16*16*128*9*3)+3)
local array = ffi.cast("double*", blob:getPointer())

while true do    
    message = channel:pop(false)
    if message then
        local c_array = ffi.cast("double*", message:getPointer())   
        local cx,cz = c_array[1],c_array[2]
        --overwrite
        --(chunk size * double byte usage * data) + usage for chunk_x and chunk_z
        c_array = nil
        

        local chunk = {x=cx,z=cz,data = {}}

        local x,y,z = 0,0,0
        --get real position for noise
        local noise = math.ceil(lovr.math.noise((x+(cx*16))/100, ((cz*16)+z)/100,seed)*100)
        local index
        local count = 0
        for i = 1,16*16*128 do
            
            index = hash_position(x,y,z)
            
            count = count + 1
            array[count] = index

            if y == noise then
                count = count + 1
                array[count] = 3 --block

                count = count + 1
                array[count] = 15 --light

            elseif y >= noise - 3 and y <= noise - 1 then
                count = count + 1
                array[count] = 1 --block
                
                count = count + 1
                array[count] = 15 --light

            elseif y < noise - 3 then
                count = count + 1
                array[count] = 2 --block
                
                count = count + 1
                array[count] = 15 --light
            else
                count = count + 1
                array[count] = 0 --block
                
                count = count + 1
                array[count] = 15 --light
            end
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
        
        --reserve this for next step
        array[0] = count

        count = count + 1
        array[count] = cx

        count = count + 1
        array[count] = cz

        channel2:push(blob,false)
    end
end
]]


vertex_generator_code = [[
local lovr = { thread = require 'lovr.thread', math = require 'lovr.math', timer = require 'lovr.timer', data = require 'lovr.data'}
local ffi = require('ffi')
local channel3 = lovr.thread.getChannel("chunk_mesh")
local channel4 = lovr.thread.getChannel("chunk_mesh_receive")
local seed = lovr.math.random()

--this is the calculator for hashing positions in the 1D memory
--of the chunk sanbox
function hash_position(x,y,z)
	return (z + 64) * 128 * 128
		 + (y + 64) * 128
		 + (x + 64)
end


local vertex_blob = lovr.data.newBlob(9437184)
local vertex_array = ffi.cast("double*", vertex_blob:getPointer())

local message
local max_ids = 4
local index_translation = {1,  2,  3,  1,  3,  4 }

while true do
    message = channel3:pop(false)

    if message then
        
        --local time = lovr.timer.getTime()

        local array = ffi.cast("double*", message:getPointer()) 
        
        --
        local i_count = array[0]

        local count = 0

        --local hash = core.hash_chunk_position(array[i_count+1],array[i_count+2])

        chunk_data = {}
        local array_index
        local block_index
        while count < i_count do
            count = count + 1

            array_index = array[count]

            chunk_data[array_index] = {}

            block_index = chunk_data[array_index]

            count = count + 1
            block_index.block = array[count]

            count = count + 1
            block_index.light = array[count]
        end
        --

        local chunk_x,chunk_z = array[i_count+1],array[i_count+2]

        array = nil
        --print(lovr.timer.getTime() - time)

        local function get_block(x,y,z)
            --hash the position so that the 
            --1D chunk map can be indexed properly
            local hash = hash_position(x,y,z)
            --if the chunk exists, index
            if chunk_data[hash] then
                return(chunk_data[hash].block)
            end
        end

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

        local x = 0
        local y = 0
        local z = 0

        --this needs to be included to incorperate the literal
        --position in memory and in game
        local adjuster_x = chunk_x*16
        local adjuster_z = chunk_z*16

        local r,g,b,a

        local index
        local data
        local light
        local id_min
        local id_max
        local block_pick

        --this is 1 through the max chunk size in a 1D memory map,
        --which is 65,536. This is why each index is hashed to utilize
        --the raw performance of the cpu with a better memory handling
        --to provide extreme performance.
        for i = 1,16*16*128 do
            --hash position and get data
            index = hash_position(x,y,z)
            data = get_block(x,y,z)--chunk_data[index].block
            light = 1--math.random()--chunk_data[index].light/15
            --io.write(data.."\n")
            if data and data > 0 then
                r,g,b,a = light,light,light,1

                --this moves the pointer of the beginning and ending of
                --the texture atlas, this is only 2D for now so only the
                --X axis is being utilized
                id_min = (data/max_ids)-shift
                id_max = (data/max_ids)

                --yes, this was extremely tedious to program

                block_pick = get_block(x,y,z-1)
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

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_min, 0, 0, 0,-1, r,g,b,a} -- 0,0,0 -- 0, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_min, 1, 0, 0,-1, r,g,b,a} -- 0,1,0 -- 0, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_max, 1, 0, 0,-1, r,g,b,a} -- 1,1,0 -- 1, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_max, 0, 0, 0,-1, r,g,b,a} -- 1,0,0 -- 1, 0
                end

                block_pick = get_block(x,y+1,z)
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

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_min, 0, 0, 1, 0, r,g,b,a} -- 1,1,0 -- 0, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_min, 1, 0, 1, 0, r,g,b,a} -- 0,1,0 -- 0, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_max, 1, 0, 1, 0, r,g,b,a} -- 0,1,1 -- 1, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_max, 0, 0, 1, 0, r,g,b,a} -- 1,1,1 -- 1, 0
                end

                block_pick = get_block(x+1,y,z)
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

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_min, 0, 1, 0, 0, r,g,b,a} -- 1,0,0 -- 0, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+0+adjuster_z, id_min, 1, 1, 0, 0, r,g,b,a} -- 1,1,0 -- 0, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_max, 1, 1, 0, 0, r,g,b,a} -- 1,1,1 -- 1, 1

                    vertex_count = vertex_count + 1
                    
                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_max, 0, 1, 0, 0, r,g,b,a} -- 1,0,1 -- 1, 0

                end

                block_pick = get_block(x-1,y,z)
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

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_max, 0,-1, 0, 0, r,g,b,a} -- 0,0,0 -- 1, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_min, 0,-1, 0, 0, r,g,b,a} -- 0,0,1 -- 0, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_min, 1,-1, 0, 0, r,g,b,a} -- 0,1,1 -- 0, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+0+adjuster_z, id_max, 1,-1, 0, 0, r,g,b,a} -- 0,1,0 -- 1, 1
                end

                block_pick = get_block(x,y,z+1)
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

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+1, z+1+adjuster_z, id_min, 1, 0, 0, 1, r,g,b,a} -- 1,1,1 -- 0, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+1, z+1+adjuster_z, id_max, 1, 0, 0, 1, r,g,b,a} -- 0,1,1 -- 1, 1

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_max, 0, 0, 0, 1, r,g,b,a} -- 0,0,1 -- 1, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_min, 0, 0, 0, 1, r,g,b,a} -- 1,0,1 -- 0, 0

                end
                

                block_pick = get_block(x,y-1,z)
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

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+0+adjuster_z, id_max, 1, 0,-1, 0, r,g,b,a} -- 0,0,0 -- 1, 1

                    vertex_count = vertex_count + 1
                    
                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+0+adjuster_z, id_max, 0, 0,-1, 0, r,g,b,a} -- 1,0,0 -- 1, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+1+adjuster_x, y+0, z+1+adjuster_z, id_min, 0, 0,-1, 0, r,g,b,a} -- 1,0,1 -- 0, 0

                    vertex_count = vertex_count + 1

                    chunk_vertices[vertex_count] = { x+0+adjuster_x, y+0, z+1+adjuster_z, id_min, 1, 0,-1, 0, r,g,b,a} -- 0,0,1 -- 0, 1
                
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

        --print("vertex: "..vertex_count*12)
        --print("vertex_tables:"..vertex_count)
        --print("index: "..index_count)
        --overwrite
        --(reserved+(vertex_count*table values)+reserved+index_count)*bytes needed per double
        

        vertex_array[0] = vertex_count*12

        local count = 0
        local real_count = 0

        while count < vertex_count do
            count = count + 1
            for i = 1,12 do
                real_count = real_count + 1
                vertex_array[real_count] = chunk_vertices[count][i]
            end
        end

        real_count = real_count + 1
        vertex_array[real_count] = index_count

        local count = 0
        while count < index_count do
            count = count + 1
            real_count = real_count + 1
            vertex_array[real_count] = chunk_indexes[count]
        end

        --print(chunk_x,chunk_z)
        real_count = real_count + 1
        vertex_array[real_count] = chunk_x

        real_count = real_count + 1
        vertex_array[real_count] = chunk_z
        channel4:push(vertex_blob,false)
    end
end
]]





function lovr.threaderror(thread, message)
    print(thread,message)
end


