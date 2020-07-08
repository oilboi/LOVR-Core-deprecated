lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'
require 'input'
require 'camera'


function lovr.load()
    lovr.mouse.setRelativeMode(true)

    camera = {
        transform = lovr.math.newMat4(),
        position = lovr.math.newVec3(),
        movespeed = 10,
        pitch = 0,
        yaw = 0
    }
end

function lovr.update(dt)
    camera_look(dt)
end

function lovr.draw()
    --this is transformed from the camera rotation class
    lovr.graphics.transform(mat4(camera.transform):invert())

    lovr.graphics.push()

    
    
    
    lovr.graphics.setColor(0xffffff)
    lovr.graphics.plane('fill', 0, 0, 0, 10, 10, math.pi / 2, 1, 0, 0)

    lovr.graphics.pop()
end