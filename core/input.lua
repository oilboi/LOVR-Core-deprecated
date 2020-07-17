function lovr.keypressed(key)
    if key == "escape" then
        lovr.event.quit()
    end
end


local cool_down = 0
function core.dig(dt)
    if cool_down <= 0 then
        if lovr.mouse.isDown(1)then
            core.raycast(4)
            if core.selected_block then
                local id = core.get_block(core.selected_block.x,core.selected_block.y,core.selected_block.z)
                if id ~= 0 then
                    cool_down = 0.25
                    core.set_block(core.selected_block.x,core.selected_block.y,core.selected_block.z,0)
                    core.add_item(core.selected_block.x+0.5,core.selected_block.y+0.5,core.selected_block.z+0.5,id)
                end
            end
        elseif lovr.mouse.isDown(2) then
            core.raycast(4)
            if core.selected_block then
                if core.selected_block_above and core.get_block(core.selected_block_above.x,core.selected_block_above.y,core.selected_block_above.z) == 0 then
                    cool_down = 0.25
                    core.set_block(core.selected_block_above.x,core.selected_block_above.y,core.selected_block_above.z,4)--lovr.math.random(1,2))
                end
            end
        end
    else
        cool_down = cool_down - dt
        if cool_down <= 0 then
            cool_down = 0
        end
    end
end


function lovr.mousemoved(x, y, dx, dy)

    core.camera.pitch = core.camera.pitch - dy * .001

    if core.camera.pitch > math.pi/2 then
        core.camera.pitch = math.pi/2
    elseif core.camera.pitch < -math.pi/2 then
        core.camera.pitch = -math.pi/2
    end   

    core.camera.yaw   = core.camera.yaw   - dx * .001

    if core.camera.yaw < -math.pi then
        core.camera.yaw = math.pi + (core.camera.yaw+math.pi)
    elseif core.camera.yaw > math.pi then
        core.camera.yaw = -math.pi + (core.camera.yaw-math.pi)
    end
end
