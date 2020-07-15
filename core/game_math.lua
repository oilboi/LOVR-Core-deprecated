--this is the calculator for hashing positions in the 1D memory
--of the chunk map
function hash_chunk_position(x,z)
	return (x + 1073741823) * 512
		+  (z + 1073741823)
end

--this inverses the above function
function get_chunk_from_hash(hash)
    local x = (hash % 2147483646) - 1073741823
    hash = math.floor(hash / 2147483646) 
    local z = (hash % 2147483646) - 1073741823
	return x,z
end

--this is the calculator for hashing positions in the 1D memory
--of the chunk sanbox
function hash_position(x,y,z)
	return (z + 64) * 128 * 128
		 + (y + 64) * 128
		 + (x + 64)
end

--this inverses the function above
function get_position_from_hash(hash)
    local x = (hash % 128) - 64
    hash  = math.floor(hash / 128)    
    local y = (hash % 128) - 64
    hash  = math.floor(hash / 128)
    local z = (hash % 128) - 64
	return x,y,z
end

--this gets the distance between two points
function distance(a, b)
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--create a new vector
function new_vec(x,y,z)
    return({x=x,y=y,z=z})
end

--hypotenuse of a right triangle
function math.hypot(x, y)
    local t
    
	x = math.abs(x)
	y = math.abs(y)
	v = math.min(x, y)
	x = math.max(x, y)
	v = v / x
	return x * math.sqrt(1 + v * v)
end

--direction between two vectors
function vec_direction(a,b)
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