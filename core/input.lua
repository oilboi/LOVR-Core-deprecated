function lovr.keypressed(key)
    if key == "escape" then
        lovr.event.quit()
    end
end

function lovr.mousepressed(x, y, button)
    if x then
        set_block(x,127,0)

        local cx,cy,cz = camera.position:unpack()

        local dir = {x=math.cos(-camera.yaw),z=math.sin(-camera.yaw),y=math.sin(camera.pitch)}
    
        dir.x = dir.x * 4
        dir.y = dir.y * 4
        dir.z = dir.z * 4

        local pos = {x=math.floor(-cz+dir.x+0.5),y=math.floor(cy+dir.y-0.5),z=math.floor(cx+dir.z-0.5)}
        set_block(pos.x,pos.y,pos.z,0)
    end
end

function lovr.mousemoved(x, y, dx, dy)

    camera.pitch = camera.pitch - dy * .001

    if camera.pitch > math.pi/2 then
        camera.pitch = math.pi/2
    elseif camera.pitch < -math.pi/2 then
        camera.pitch = -math.pi/2
    end   

    camera.yaw   = camera.yaw   - dx * .001

    if camera.yaw < -math.pi then
        camera.yaw = math.pi + (camera.yaw+math.pi)
    elseif camera.yaw > math.pi then
        camera.yaw = -math.pi + (camera.yaw-math.pi)
    end

end
