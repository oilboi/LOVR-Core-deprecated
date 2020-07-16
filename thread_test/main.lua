function lovr.load()
    x = 0

    thread_code = [[
        local lovr = { thread = require 'lovr.thread' }
        local channel = lovr.thread.getChannel("test")
        local x = 0
        while true do
            x = x + 1
            channel:push(x)
        end
    ]]

    channel = lovr.thread.getChannel("test")

    thread = lovr.thread.newThread(thread_code)

    thread:start()
end


function lovr.update(dt)
    message = channel:pop()
end


function lovr.draw()
    lovr.graphics.print(tostring(message), 0, 1.7, -5)
end