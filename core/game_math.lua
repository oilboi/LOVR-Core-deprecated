function hash_chunk_position(x,z)
	return (x + 1073741823) * 512
		+  (z + 1073741823)
end

function get_chunk_from_hash(hash)
    local x = (hash % 2147483646) - 1073741823

    hash = math.floor(hash / 2147483646) 
    
    local z = (hash % 2147483646) - 1073741823

	return x,z
end


function hash_position(x,y,z)
	return (z + 64) * 128 * 128
		 + (y + 64) * 128
		 + (x + 64)
end

function get_position_from_hash(hash)
    local x = (hash % 128) - 64
    hash  = math.floor(hash / 128)    
    local y = (hash % 128) - 64
    hash  = math.floor(hash / 128)
    local z = (hash % 128) - 64
	return x,y,z
end