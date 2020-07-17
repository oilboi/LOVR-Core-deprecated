function core.get_block(x,y,z)
    local chunk_x = math.floor(x/16)
    local chunk_z = math.floor(z/16)

    local relative_x = x-(chunk_x*16)
    local relative_z = z-(chunk_z*16)

    local hash = core.hash_chunk_position(chunk_x,chunk_z)

    if core.chunk_map[hash] then
        local index = core.hash_position(relative_x,y,relative_z)
        if core.chunk_map[hash][index] then
            return(core.chunk_map[hash][index].block)
        else
            return(0)
        end
    end
end


function core.set_block(x,y,z,block)
    --interpret 
    local chunk_x = math.floor(x/16)
    local chunk_z = math.floor(z/16)

    local relative_x = x-(chunk_x*16)
    local relative_z = z-(chunk_z*16)

    local hash = core.hash_chunk_position(chunk_x,chunk_z)

    if core.chunk_map[hash] then
        --set the data
        local index = core.hash_position(relative_x,y,relative_z)
        core.chunk_map[hash][index].block = block
        --update the mesh
        core.chunk_update_vert(chunk_x,chunk_z)

        --update X neighbor if on a chunk border
        if relative_x == 15 then
            core.chunk_update_vert(chunk_x+1,chunk_z)
        elseif relative_x == 0 then
            core.chunk_update_vert(chunk_x-1,chunk_z)
        end
        --update Z neighbor if on a chunk border
        if relative_z == 15 then
            core.chunk_update_vert(chunk_x,chunk_z+1)
        elseif relative_z == 0 then
            core.chunk_update_vert(chunk_x,chunk_z-1)
        end
    end
end


function core.vector_to_dir(x,y,z)
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


function core.get_camera_dir()
    return math.cos(core.camera.pitch) * math.cos(-core.camera.yaw-math.pi/2),
           math.sin(core.camera.pitch),
           math.cos(core.camera.pitch) * math.sin(-core.camera.yaw-math.pi/2)
end


--this garbage needs to be rewritten
function core.raycast(length)
    --local time = lovr.timer.getTime()
    local r_length = 0
    local x,y,z
    local cx,cy,cz = core.camera.pos.x,core.camera.pos.y,core.camera.pos.z--camera.position:unpack()
    
    local dx,dy,dz = core.get_camera_dir()

    local solved = false
    while  solved == false do
        r_length = r_length + 0.0001
        x = math.floor(cx + (dx*r_length))
        y = math.floor(cy + (dy*r_length))
        z = math.floor(cz + (dz*r_length))

        local found_block = core.get_block(x,y,z)

        if found_block and found_block > 0 then
            local check_x,check_y,check_z = core.vector_to_dir(
                -dx,
                -dy,
                -dz
            )
            core.selected_block = {x=x,y=y,z=z}
            core.selected_block_above = {x=x+check_x,y=y+check_y,z=z+check_z}
            return
         end
        if r_length >= length then
            solved = true
            core.selected_block = nil
            core.selected_block_above = nil
        end
    end
    --timer = lovr.timer.getTime() - time
end
