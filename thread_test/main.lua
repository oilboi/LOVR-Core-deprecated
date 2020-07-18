thread_code = [[
        local lovr = { thread = require 'lovr.thread' }
        local channel = lovr.thread.getChannel("send")
        local channel2 = lovr.thread.getChannel("receive")
        while true do
            local x = channel:pop(false)
            
            if x then
                x = x * 2
                channel2:push(x,false)
            end
        end
    ]]


function lovr.load()    
    channel = lovr.thread.getChannel("send")
    channel2 = lovr.thread.getChannel("receive")

    thread = lovr.thread.newThread(thread_code)    
    thread:start()

    message = 1

    channel:push(1)
end


function lovr.update(dt)
    local x = channel2:pop(false)
    if x then
        message = x
        channel:push(x*2,false)
    end
end


function lovr.draw()
    lovr.graphics.print(tostring(message), 0, 1.7, -5)
end