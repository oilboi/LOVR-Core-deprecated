local ffi = require('ffi')

function lovr.load()
    
end


function lovr.update()
    lovr.event.pump()

    local blob = lovr.data.newBlob(16*16*128*8)
    local array = ffi.cast("double*", blob:getPointer())
    for i = 1,16*16*128 do
        array[i] = i
        local lag = array[i]
    end
    io.write("done")
    io.write("\n")
end



function lovr.draw()
    local fps = lovr.timer.getFPS()
    lovr.graphics.print(tostring(fps), 0, 1.7, -5)
end