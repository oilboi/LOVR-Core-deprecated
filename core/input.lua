function lovr.keypressed(key)
    if key == "escape" then
        lovr.event.quit()
    end
end

function dig()
    raycast(4)
    
    if lovr.mouse.isDown(1) and selected_block then
        if global_block_check(selected_block.x,selected_block.y,selected_block.z) ~= 0 then
            set_block(selected_block.x,selected_block.y,selected_block.z,0)
        end
    elseif lovr.mouse.isDown(2) then    
        if selected_block_above and global_block_check(selected_block_above.x,selected_block_above.y,selected_block_above.z) == 0 then
            set_block(selected_block_above.x,selected_block_above.y,selected_block_above.z,lovr.math.random(1,2))
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
