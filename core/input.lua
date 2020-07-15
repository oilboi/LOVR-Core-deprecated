--this is an easy way to exit the game
function lovr.keypressed(key)
    if key == "escape" then
        lovr.event.quit()
    end
end

--this is a simple function that allows players to
--modify the terrain
function dig()
    
    if lovr.mouse.isDown(1)then
        raycast(4)
        if selected_block then
            if get_block(selected_block.x,selected_block.y,selected_block.z) ~= 0 then
                set_block(selected_block.x,selected_block.y,selected_block.z,0)

                add_item(selected_block.x+0.5,selected_block.y+0.5,selected_block.z+0.5)
            end
        end
    elseif lovr.mouse.isDown(2) then
        raycast(4)
        if selected_block then
            if selected_block_above and get_block(selected_block_above.x,selected_block_above.y,selected_block_above.z) == 0 then
                set_block(selected_block_above.x,selected_block_above.y,selected_block_above.z,4)--lovr.math.random(1,2))
            end
        end
    end
end

--this moves the pitch and yaw of the camera
--based on the delta of the 2D mouse input
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
