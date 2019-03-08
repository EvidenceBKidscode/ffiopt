ffiopt.ffi.cdef[[
typedef struct MapData { uint16_t param0; uint8_t param1; uint8_t param2; } mapdata_t;
]]

-- TODO: Protect pointer for getting outside map data

local data_metatable = {
	__index = function(tbl, ix)
			if ix > 0 and ix <= tbl.volume then
				return tbl.ptr[ix-1].param0
			end
		end,
	__newindex = function(tbl, ix, val)
			if ix > 0 and ix <= tbl.volume then
				tbl.ptr[ix-1].param0 = val
			end
		end,
}

local function get_data(self, target)
	local data = target or {}
	-- Empty table (in case of given target table)
	local count = #data
	for i = 1, count do rawset(data, i, nil) end

	local emin, emax = self:get_emerged_area()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	data.volume = area:getVolume()
	data.ptr = ffiopt.ffi.cast('mapdata_t*', self:get_data_ptr())
	setmetatable(data, data_metatable)
end

local function get_voxel_manip(p1, p2)
	local vm = std_get_voxel_manip(p1, p2)
	std_get_data = vm.get_data
	vm.get_data = get_data
	vm.set_data = function() end
end

minetest.after(0, function()
	local mt = getmetatable(minetest.get_voxel_manip())
	if mt['get_data_ptr'] then
		minetest.log("action", string.format("[%s] VoxelManip can be optimized.",
			ffiopt.name))
		mt['get_data'] = get_data
		mt['set_data'] = function() end
	else
		minetest.log("warning", string.format("[%s] No optimisation for VoxelManip, missing get_data_ptr method.",
			ffiopt.name))
	end
end)
