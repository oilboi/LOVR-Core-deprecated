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

aabb_physics = function(self)
    -- apply gravity and friction
    self.speed.x = self.speed.x * self.friction
    self.speed.z = self.speed.z * self.friction
    self.speed.y = self.speed.y - 0.003

    -- determine if player has hit ground this frame
    self.on_ground = false
    if tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.speed.y,self.pos.z+self.width))
    or tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.speed.y,self.pos.z-self.width))
    or tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.speed.y,self.pos.z+self.width))
    or tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.speed.y,self.pos.z-self.width)) then
        local i = 0
        while not tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+i,self.pos.z+self.width))
        and not tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+i,self.pos.z-self.width))
        and not tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+i,self.pos.z+self.width))
        and not tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+i,self.pos.z-self.width)) do
            i = i-0.01
        end
        self.pos.y = self.pos.y + i+0.01
        self.speed.y = 0
        self.on_ground = true
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
    if lovr.keyboard.isDown("space") and self.on_ground then
        self.speed.y = self.speed.y + 0.1
    end

    -- hit head ceilings
    if math.abs(self.speed.y) == self.speed.y
    and (tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.height+self.speed.y,self.pos.z+self.width))
    or   tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.height+self.speed.y,self.pos.z-self.width))
    or   tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.height+self.speed.y,self.pos.z+self.width))
    or   tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.height+self.speed.y,self.pos.z-self.width))) then
        self.speed.y = -0.5 * self.speed.y
    end

    -- convert WASD keys pressed into an angle, move xSpeed and zSpeed according to cos and sin
    
    if moving then
        local angle = math.angle(0,0, mx,my)
        self.direction = (camera.yaw + angle)*-1 +math.pi/2
        self.speed.x = self.speed.x + math.cos(-camera.yaw + angle) * self.move_speed
        self.speed.z = self.speed.z + math.sin(-camera.yaw + angle) * self.move_speed
    end

    -- y values are good, cement them
    self.pos.y = self.pos.y + self.speed.y

    -- check for collisions with walls along the x direction
    if not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y,self.pos.z -self.width))
    and not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y+1,self.pos.z -self.width))
    and not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y,self.pos.z +self.width))
    and not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y+1,self.pos.z +self.width)) then
        -- x values are good, cement them
        self.pos.x = self.pos.x + self.speed.x
    else
        self.speed.x = 0
    end

    -- check for collisions with walls along the z direction
    if not tile_collisions(physics_get_block(self.pos.x -self.width,self.pos.y,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width))
    and not tile_collisions(physics_get_block(self.pos.x -self.width,self.pos.y+1,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width))
    and not tile_collisions(physics_get_block(self.pos.x +self.width,self.pos.y,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width))
    and not tile_collisions(physics_get_block(self.pos.x +self.width,self.pos.y+1,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width)) then
        -- z values are good, cement them
        self.pos.z = self.pos.z + self.speed.z
    else
        self.speed.z = 0
    end
end

entity_aabb_physics = function(self)
    -- apply gravity and friction
    self.speed.x = self.speed.x * self.friction
    self.speed.z = self.speed.z * self.friction
    self.speed.y = self.speed.y - 0.003

    -- determine if player has hit ground this frame
    self.on_ground = false
    if tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.speed.y,self.pos.z+self.width))
    or tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.speed.y,self.pos.z-self.width))
    or tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.speed.y,self.pos.z+self.width))
    or tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.speed.y,self.pos.z-self.width)) then
        local i = 0
        while not tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+i,self.pos.z+self.width))
        and not tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+i,self.pos.z-self.width))
        and not tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+i,self.pos.z+self.width))
        and not tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+i,self.pos.z-self.width)) do
            i = i-0.01
        end
        self.pos.y = self.pos.y + i+0.01
        self.speed.y = 0
        self.on_ground = true
    end

    -- hit head ceilings
    if math.abs(self.speed.y) == self.speed.y
    and (tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.height+self.speed.y,self.pos.z+self.width))
    or   tile_collisions(physics_get_block(self.pos.x-self.width,self.pos.y+self.height+self.speed.y,self.pos.z-self.width))
    or   tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.height+self.speed.y,self.pos.z+self.width))
    or   tile_collisions(physics_get_block(self.pos.x+self.width,self.pos.y+self.height+self.speed.y,self.pos.z-self.width))) then
        self.speed.y = -0.5 * self.speed.y
    end

    -- convert WASD keys pressed into an angle, move xSpeed and zSpeed according to cos and sin
    
    if moving then
        local angle = math.angle(0,0, mx,my)
        self.direction = (camera.yaw + angle)*-1 +math.pi/2
        self.speed.x = self.speed.x + math.cos(-camera.yaw + angle) * self.move_speed
        self.speed.z = self.speed.z + math.sin(-camera.yaw + angle) * self.move_speed
    end

    -- y values are good, cement them
    self.pos.y = self.pos.y + self.speed.y

    -- check for collisions with walls along the x direction
    if not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y,self.pos.z -self.width))
    and not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y+1,self.pos.z -self.width))
    and not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y,self.pos.z +self.width))
    and not tile_collisions(physics_get_block(self.pos.x+self.speed.x +GetSign(self.speed.x)*self.width,self.pos.y+1,self.pos.z +self.width)) then
        -- x values are good, cement them
        self.pos.x = self.pos.x + self.speed.x
    else
        self.speed.x = 0
    end

    -- check for collisions with walls along the z direction
    if not tile_collisions(physics_get_block(self.pos.x -self.width,self.pos.y,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width))
    and not tile_collisions(physics_get_block(self.pos.x -self.width,self.pos.y+1,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width))
    and not tile_collisions(physics_get_block(self.pos.x +self.width,self.pos.y,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width))
    and not tile_collisions(physics_get_block(self.pos.x +self.width,self.pos.y+1,self.pos.z+self.speed.z +GetSign(self.speed.z)*self.width)) then
        -- z values are good, cement them
        self.pos.z = self.pos.z + self.speed.z
    else
        self.speed.z = 0
    end
end