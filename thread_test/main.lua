thread_code = [[
        local lovr = { thread = require 'lovr.thread' }
        local channel = lovr.thread.getChannel("send")
        local channel2 = lovr.thread.getChannel("receive")
        local channel3 = lovr.thread.getChannel("somethingelse")
        while true do
            local x = channel:pop(false)
            
            if x then
                x = x + 2
                channel2:push(x,false)
            end
        end
    ]]
thread_code2 = [[
        local lovr = { thread = require 'lovr.thread' }
        local channel = lovr.thread.getChannel("send")
        local channel2 = lovr.thread.getChannel("receive")
        local channel3 = lovr.thread.getChannel("somethingelse")
        while true do
            local x = channel2:pop(false)
            
            if x then
                x = x + 2
                channel3:push(x,false)
            end
        end
    ]]

function lovr.load()    
    channel = lovr.thread.getChannel("send")
    channel2 = lovr.thread.getChannel("receive")
    channel3 = lovr.thread.getChannel("somethingelse")

    thread = lovr.thread.newThread(thread_code)
    thread:start()

    thread2 = lovr.thread.newThread(thread_code2)
    thread2:start()

    message = 1

    channel:push(1)
end


function lovr.update(dt)
    local x = channel3:pop(false)
    if x then
        message = x
        channel:push(x + 2,false)
    end
end


function lovr.draw()
    lovr.graphics.print(tostring(message), 0, 1.7, -5)
end