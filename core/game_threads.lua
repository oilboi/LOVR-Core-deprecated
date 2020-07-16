thread_code = [[
local lovr = { thread = require 'lovr.thread', math = require 'lovr.math' }
local json = require 'cjson'
local channel = lovr.thread.getChannel("vertex")
local channel2 = lovr.thread.getChannel("vertex_receive")
local seed = lovr.math.random()

--this is the calculator for hashing positions in the 1D memory
--of the chunk sanbox
function hash_position(x,y,z)
	return (z + 64) * 128 * 128
		 + (y + 64) * 128
		 + (x + 64)
end

local thread_storage = {}

local message

while true do
    message = channel:pop()

    if message then
        local decoded = json.decode(message)
        local cx,cz = decoded.x,decoded.z
        local chunk = {x=cx,z=cz,data = {}}
        local x,y,z = 0,0,0
        --this is subtracting the position that the chunk roots in and then adding positional data
        --to the literal position inside of the chunk so that the noise generation follows
        --the noise generation in sync with the rest of the map
        local noise = math.ceil(lovr.math.noise((x+(cx*16))/100, ((cz*16)+z)/100,seed)*100)
        local index
        local count = 0
        for i = 1,16*16*128 do
            index = hash_position(x,y,z)
            count = count + 1
            if y == noise then
                chunk.data[count] = {index = index,block=3,light=15}--lovr.math.random(1,3)
            elseif y >= noise - 3 and y <= noise - 1 then
                chunk.data[count] = {index = index,block=1,light=0}
            elseif y < noise - 3 then
                chunk.data[count] = {index = index,block=2,light=0}
            else
                chunk.data[count] = {index = index,block=0,light=0}
            end
            --this is using literal counting to extract the full
            --performance from luajit since the table[#table] and
            --table[table.getn(table)] operators are extremely
            --slow in comparison
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
        channel2:push(json.encode(chunk))
    end
end
]]