function lovr.keypressed(key)
    if key == "escape" then
        lovr.event.quit()
    end
end

function dig()
    if lovr.mouse.isDown(1) then
        local cx,cy,cz = camera.position:unpack()

        local dx,dy,dz = get_camera_dir()
        dx = dx * 4
        dy = dy * 4
        dz = dz * 4
        local pos = {x=-cz+dx,y=cy+dy,z=cx+dz}
        pos.x =math.floor( pos.x )
        pos.y =math.floor( pos.y )
        pos.z =math.floor( pos.z )
        if block_check(pos.x,pos.y,pos.z) ~= 0 then
            set_block(pos.x,pos.y,pos.z,0)
        end
    elseif lovr.mouse.isDown(2) then    
            local cx,cy,cz = camera.position:unpack()
    
            local dx,dy,dz = get_camera_dir()
            dx = dx * 4
            dy = dy * 4
            dz = dz * 4
            local pos = {x=-cz+dx,y=cy+dy,z=cx+dz}
            pos.x =math.floor( pos.x )
            pos.y =math.floor( pos.y )
            pos.z =math.floor( pos.z )
            if block_check(pos.x,pos.y,pos.z) == 0 then
                set_block(pos.x,pos.y,pos.z,lovr.math.random(1,2))
            end
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
