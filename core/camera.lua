local fov_mod = 0
local up = true
function camera_look(dt)
    local velocity = {x=0,y=0,z=0}

    if lovr.keyboard.isDown('w', 'up') then
        velocity.z = 1
        --[[
        fov = fov - dt*100
        if fov < fov_origin-20 then
            fov = fov_origin-20
        end
        ]]--
    elseif lovr.keyboard.isDown('s', 'down') then
        velocity.z = -1
        --[[
        fov = fov + dt*100
        if fov > fov_origin+20 then
            fov = fov_origin+20
        end
        ]]--
    end

    --[[
    if gen_complete then
        if up then
            fov_mod = fov_mod + dt*50
            if fov_mod >= 15 then
                up = not up
            end
        else
            fov_mod = fov_mod - dt*50
            if fov_mod <= -15 then
                up = not up
            end
        end
    end
    fov = fov_origin + fov_mod
    ]]--
    --[[
    if fov < fov_origin and velocity.z == 0 then
        fov = fov + dt*100
        if fov > fov_origin then
            fov = fov_origin
        end
    elseif fov > fov_origin and velocity.z == 0 then
        fov = fov - dt*100
        if fov < fov_origin then
            fov = fov_origin
        end
    end
    ]]--

    if lovr.keyboard.isDown('a', 'left') then
        velocity.x = -1        
    elseif lovr.keyboard.isDown('d', 'right') then
        velocity.x = 1
    end

    
    if lovr.keyboard.isDown('lshift') then
        velocity.y = -1
    elseif lovr.keyboard.isDown('space') then
        velocity.y = 1
    end    
    
    if velocity.x ~= 0 or velocity.z ~= 0 then
        local yaw_translate = camera.yaw

        key_global = yaw_translate

        if velocity.x == 1 and velocity.z == -1 then
            yaw_translate = camera.yaw-(math.pi*0.75)
        elseif velocity.x == -1 and velocity.z == -1 then
            yaw_translate = camera.yaw+(math.pi*0.75)
        elseif velocity.x == 1 and velocity.z == 1 then
            yaw_translate = camera.yaw+(math.pi*1.75)
        elseif velocity.x == -1 and velocity.z == 1 then
            yaw_translate = camera.yaw-(math.pi*1.75)

        elseif velocity.z == 1 then
            yaw_translate = yaw_translate
        elseif velocity.z == -1 then
            yaw_translate = yaw_translate+math.pi
        elseif  velocity.x == -1 then
            yaw_translate = yaw_translate + math.pi/2
        elseif  velocity.x == 1 then
            yaw_translate = yaw_translate - math.pi/2
        end

        velocity.x = -math.sin(yaw_translate)
        velocity.z = -math.cos(yaw_translate)
        --velocity:normalize()
        --velocity:mul(camera.movespeed * dt)

        --local t = camera.transform:mul(velocity).xyz

        t = lovr.math.vec3(velocity.x,0,velocity.z)
        

        t:normalize()

        t:mul(camera.movespeed * dt)

        camera.position:add(t)
    end


    if velocity.y ~= 0 then
        velocity.y = velocity.y * dt * camera.movespeed

        local Q = lovr.math.vec3(0,velocity.y,0)

        camera.position:add(Q)
    end

    --io.write(math.floor(camera.position.x).." "..math.floor(camera.position.z).."\n")
    
    --camera.transform:identity()

    --camera.transform:add(lovr.math.vec3(0, 1.7, 0))

    --camera.transform:add(camera.position)

    --camera.transform:rotate(camera.yaw, 0, 1, 0)

    --camera.transform:rotate(camera.pitch, 1, 0, 0)
end

--this is a useful function for easily allowing look direction
function get_camera_dir()
    return math.cos(camera.pitch) * math.cos(-camera.yaw-math.pi/2),
           math.sin(camera.pitch),
           math.cos(camera.pitch) * math.sin(-camera.yaw-math.pi/2)
end

function vector_to_dir(x,y,z)
	if math.abs(y) > math.abs(x) and math.abs(y) > math.abs(z) then
		-- above
		if y < 0 then
            return 0,-1,0
		-- under
        else
            return 0,1,0
		end
    elseif math.abs(x) > math.abs(z) then
        -- left
		if x < 0 then
            return -1,0,0
        -- right
		else
			return 1,0,0
		end
    else
        -- forwards
		if z < 0 then
            return 0,0,-1
        -- backwards
		else
			return 0,0,1
		end
	end
end



function raycast(length)
    --local time = lovr.timer.getTime()
    local r_length = 0
    local x,y,z
    local cx,cy,cz = camera.position:unpack()
    
    local dx,dy,dz = get_camera_dir()

    local solved = false
    while  solved == false do
        r_length = r_length + 0.05
        x = math.floor(cx + (dx*r_length))
        y = math.floor(cy + (dy*r_length))
        z = math.floor(cz + (dz*r_length))

        local found_block = block_check(x,y,z)

        if found_block and found_block > 0 then
            local check_x,check_y,check_z = vector_to_dir(
                -dx,
                -dy,
                -dz
            )
            selected_block = {x=x,y=y,z=z}
            selected_block_above = {x=x+check_x,y=y+check_y,z=z+check_z}
            return
         end
        if r_length >= length then
            solved = true
            selected_block = nil
            selected_block_above = nil
        end
    end
    --timer = lovr.timer.getTime() - time
end
