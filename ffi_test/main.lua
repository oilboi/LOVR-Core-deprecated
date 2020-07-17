local ffi = require('ffi')

function lovr.load()
    
end


function lovr.update()
    lovr.event.pump()

    local blob = lovr.data.newBlob(16*16*128*10)
    local array = ffi.cast("double*", blob:getPointer())
    for i = 1,16*16*128 do
        array[i] = math.random()
    end
    io.write("done")
    io.write("\n")

    the_temp_output = array[math.random(1,16*16*128)]
end



function lovr.draw()
    local fps = lovr.timer.getFPS()
    lovr.graphics.print(tostring(fps), 0, 1.7, -5)
    lovr.graphics.print(tostring(the_temp_output), 0, 0, -5)
end
