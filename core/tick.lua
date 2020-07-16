local tick = {
    framerate = nil,
    rate = .03,
    timescale = 0.1,
    sleep = .001,
    dt = 0,
    accum = 0,
    tick = 1,
    frame = 1
  }
  
  local timer = lovr.timer
  local graphics = lovr.graphics
  
function core.tick_framerate(framerate)

    local lastframe = 0
    timer.step()
    
    tick.dt = timer.step() * tick.timescale
    
    tick.accum = tick.accum + tick.dt

    while tick.accum >= tick.rate do
        tick.accum = tick.accum - tick.rate
        --tick.tick = tick.tick + 1

        while framerate and timer.getTime() - lastframe < 1 / framerate do
            timer.sleep(.0005)
        end

        lastframe = timer.getTime()

        tick.frame = tick.frame + 1

        if lovr.draw then lovr.draw() end

    end

    timer.sleep(tick.sleep)
end
