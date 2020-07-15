-- tile enumerations stored as a function called by tile index (base 0 to accomodate air)
function tile_collisions(n)
    if n == 0 then
        return false
    end

    return true
end


-- get voxel by looking at chunk at given position's local coordinate system
function physics_get_block(x,y,z)
    return get_block(math.floor(x),math.floor(y),math.floor(z))
end

local function GetSign(n)
    if n > 0 then return 1 end
    if n < 0 then return -1 end
    return 0
end

function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

aabb_physics = function(dt)
    -- apply gravity and friction
    player.speed.x = player.speed.x * player.friction
    player.speed.z = player.speed.z * player.friction
    player.speed.y = player.speed.y - 0.003

    -- determine if player has hit ground this frame
    player.on_ground = false
    if tile_collisions(physics_get_block(player.pos.x+player.width,player.pos.y+player.speed.y,player.pos.z+player.width))
    or tile_collisions(physics_get_block(player.pos.x+player.width,player.pos.y+player.speed.y,player.pos.z-player.width))
    or tile_collisions(physics_get_block(player.pos.x-player.width,player.pos.y+player.speed.y,player.pos.z+player.width))
    or tile_collisions(physics_get_block(player.pos.x-player.width,player.pos.y+player.speed.y,player.pos.z-player.width)) then
        local i = 0
        while not tile_collisions(physics_get_block(player.pos.x+player.width,player.pos.y+i,player.pos.z+player.width))
        and not tile_collisions(physics_get_block(player.pos.x+player.width,player.pos.y+i,player.pos.z-player.width))
        and not tile_collisions(physics_get_block(player.pos.x-player.width,player.pos.y+i,player.pos.z+player.width))
        and not tile_collisions(physics_get_block(player.pos.x-player.width,player.pos.y+i,player.pos.z-player.width)) do
            i = i-0.01
        end
        player.pos.y = player.pos.y + i+0.01
        player.speed.y = 0
        player.on_ground = true
    end

    local mx,my = 0,0
    local moving = false
    
    -- take player input
    if lovr.keyboard.isDown("w") then
        mx = mx + 0
        my = my - 1

        moving = true
    end
    if lovr.keyboard.isDown("a") then
        mx = mx - 1
        my = my + 0

        moving = true
    end
    if lovr.keyboard.isDown("s") then
        mx = mx + 0
        my = my + 1

        moving = true
    end
    if lovr.keyboard.isDown("d") then
        mx = mx + 1
        my = my + 0

        moving = true
    end

    -- jump if on ground
    if lovr.keyboard.isDown("space") and player.on_ground then
        player.speed.y = player.speed.y + 0.1
    end

    -- hit head ceilings
    if math.abs(player.speed.y) == player.speed.y
    and (tile_collisions(physics_get_block(player.pos.x-player.width,player.pos.y+player.height+player.speed.y,player.pos.z+player.width))
    or   tile_collisions(physics_get_block(player.pos.x-player.width,player.pos.y+player.height+player.speed.y,player.pos.z-player.width))
    or   tile_collisions(physics_get_block(player.pos.x+player.width,player.pos.y+player.height+player.speed.y,player.pos.z+player.width))
    or   tile_collisions(physics_get_block(player.pos.x+player.width,player.pos.y+player.height+player.speed.y,player.pos.z-player.width))) then
        player.speed.y = -0.5 * player.speed.y
    end

    -- convert WASD keys pressed into an angle, move xSpeed and zSpeed according to cos and sin
    
    if moving then
        local angle = math.angle(0,0, mx,my)
        player.direction = (camera.yaw + angle)*-1 +math.pi/2
        player.speed.x = player.speed.x + math.cos(-camera.yaw + angle) * player.move_speed
        player.speed.z = player.speed.z + math.sin(-camera.yaw + angle) * player.move_speed
    end

    -- y values are good, cement them
    player.pos.y = player.pos.y + player.speed.y

    -- check for collisions with walls along the x direction
    if not tile_collisions(physics_get_block(player.pos.x+player.speed.x +GetSign(player.speed.x)*player.width,player.pos.y,player.pos.z -player.width))
    and not tile_collisions(physics_get_block(player.pos.x+player.speed.x +GetSign(player.speed.x)*player.width,player.pos.y+1,player.pos.z -player.width))
    and not tile_collisions(physics_get_block(player.pos.x+player.speed.x +GetSign(player.speed.x)*player.width,player.pos.y,player.pos.z +player.width))
    and not tile_collisions(physics_get_block(player.pos.x+player.speed.x +GetSign(player.speed.x)*player.width,player.pos.y+1,player.pos.z +player.width)) then
        -- x values are good, cement them
        player.pos.x = player.pos.x + player.speed.x
    else
        player.speed.x = 0
    end

    -- check for collisions with walls along the z direction
    if not tile_collisions(physics_get_block(player.pos.x -player.width,player.pos.y,player.pos.z+player.speed.z +GetSign(player.speed.z)*player.width))
    and not tile_collisions(physics_get_block(player.pos.x -player.width,player.pos.y+1,player.pos.z+player.speed.z +GetSign(player.speed.z)*player.width))
    and not tile_collisions(physics_get_block(player.pos.x +player.width,player.pos.y,player.pos.z+player.speed.z +GetSign(player.speed.z)*player.width))
    and not tile_collisions(physics_get_block(player.pos.x +player.width,player.pos.y+1,player.pos.z+player.speed.z +GetSign(player.speed.z)*player.width)) then
        -- z values are good, cement them
        player.pos.z = player.pos.z + player.speed.z
    else
        player.speed.z = 0
    end
end