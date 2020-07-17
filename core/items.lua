item_count = 0


function core.add_item(x,y,z,id)
    item_count = item_count + 1

    core.item_entities[item_count] = {
        pos = {x=x,y=y,z=z},
        speed = {x=math.random(-1,1)*math.random()/10,y=math.random()/10,z=math.random(-1,1)*math.random()/10},
        id = id,
        on_ground = false,
        friction = 0.85,
        height = 0.3,
        width = 0.3,
        move_speed = 0.01,
        hover_float = 0,
        up = true,
        rotation = 0,
        timer = 0,
        physical = true,
    }
end


function do_item_physics(dt)
    for index,entity in ipairs(core.item_entities) do
        entity.timer = entity.timer + dt
        if entity.up then
            entity.hover_float = entity.hover_float + dt/10
            if entity.hover_float >= 0.3 then
                entity.up = false
            end
        else
            entity.hover_float = entity.hover_float - dt/10
            if entity.hover_float <= 0 then
                entity.up = true
            end
        end

        entity.rotation = entity.rotation + dt
        if entity.rotation > math.pi then
            entity.rotation = entity.rotation - (math.pi*2)
        end

        core.entity_aabb_physics(entity)
    end
end


function draw_items()
    for _,entity in ipairs(core.item_entities) do
        core.entity_meshes[entity.id]:draw(entity.pos.x, entity.pos.y+0.3+entity.hover_float, entity.pos.z, 0.3, entity.rotation, 0, 1, 0)
    end
end


function delete_item(id)
    for i = id,item_count do
        core.item_entities[i] = core.item_entities[i+1]
    end
    core.item_entities[item_count] = nil
    item_count = item_count - 1
end


function item_magnet()
    local pos = {x=core.player.pos.x,y=core.player.pos.y,z=core.player.pos.z}
    pos.y = pos.y + 0.5
    for id,entity in ipairs(core.item_entities) do
        if entity.timer >= 2 then
            local d = core.distance(pos,entity.pos)
            if d < 0.2 then
                delete_item(id)
            elseif d < 3 then
                local v = core.vec_direction(entity.pos,pos)
                v.x = v.x/3
                v.y = v.y/3
                v.z = v.z/3

                entity.speed = v
                entity.physical = false
            end
        end
    end
end
