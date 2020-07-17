function core.hash_chunk_position(x,z)
	return (x + 1073741823) * 512
		+  (z + 1073741823)
end


function core.get_chunk_from_hash(hash)
    local x = (hash % 2147483646) - 1073741823
    hash = math.floor(hash / 2147483646) 
    local z = (hash % 2147483646) - 1073741823
	return x,z
end


function core.hash_position(x,y,z)
	return (z + 64) * 128 * 128
		 + (y + 64) * 128
		 + (x + 64)
end


function core.get_position_from_hash(hash)
    local x = (hash % 128) - 64
    hash  = math.floor(hash / 128)    
    local y = (hash % 128) - 64
    hash  = math.floor(hash / 128)
    local z = (hash % 128) - 64
	return x,y,z
end


function core.distance(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end


function core.new_vec(x,y,z)
    return({x=x,y=y,z=z})
end


function math.hypot(x, y)
    local t
    
	x = math.abs(x)
	y = math.abs(y)
	v = math.min(x, y)
	x = math.max(x, y)
	v = v / x
	return x * math.sqrt(1 + v * v)
end


function core.vec_direction(a,b)
    local v = {}
    v.x = b.x - a.x
    v.y = b.y - a.y
    v.z = b.z - a.z
    local len = math.hypot(v.x, math.hypot(v.y, v.z))
    if len == 0 then
        v.x = 0
        v.y = 0
        v.z = 0
    else
        v.x = v.x / len
        v.y = v.y / len
        v.z = v.z / len
    end
    return(v)
end
