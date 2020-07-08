function camera_look(dt)
    local velocity = vec4()

    if lovr.keyboard.isDown('w', 'up') then
        velocity.z = -1
    elseif lovr.keyboard.isDown('s', 'down') then
        velocity.z = 1
    end

    if lovr.keyboard.isDown('a', 'left') then
        velocity.x = -1
    elseif lovr.keyboard.isDown('d', 'right') then
        velocity.x = 1
    end

    local Y = 0
    if lovr.keyboard.isDown('lshift') then
        Y = -1 / camera.movespeed
    elseif lovr.keyboard.isDown('space') then
        Y = 1 / camera.movespeed
    end    

    if #velocity > 0 then
        velocity:normalize()
        velocity:mul(camera.movespeed * dt)
        local t = camera.transform:mul(velocity).xyz
        t.y = 0
        t:normalize()
        t:mul(camera.movespeed * dt)
        camera.position:add(t)
    end

    if Y then
        local Y = lovr.math.newVec3(0,Y,0)
        camera.position:add(Y)
    end
    
    camera.transform:identity()
    camera.transform:translate(0, 1.7, 0)
    camera.transform:translate(camera.position)
    camera.transform:rotate(camera.yaw, 0, 1, 0)
    camera.transform:rotate(camera.pitch, 1, 0, 0)
end
