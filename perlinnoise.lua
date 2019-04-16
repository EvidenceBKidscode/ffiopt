local result_metatable = {
	__index = function(tbl, ix)
			if ix > 0 and ix <= tbl.volume then
				return tbl.ptr[ix-1]
			end
		end,
	__newindex = function(tbl, ix, val)
			if ix > 0 and ix <= tbl.volume then
				tbl.ptr[ix-1] = val
			end
		end,
}

local function get2dMap_flat(self, pos, target)
	local result = target or {}
	-- Empty table (in case of given target table)
	local count = #result
	for i = 1, count do rawset(result, i, nil) end

	self:calc_2d_map(pos)
	result.volume = self:get_result_size()
	result.ptr = ffiopt.ffi.cast('float*', self:get_result_ptr())
	setmetatable(result, result_metatable)
	return result
end

local function get3dMap_flat(self, pos, target)
	local result = target or {}
	-- Empty table (in case of given target table)
	local count = #result
	for i = 1, count do rawset(result, i, nil) end
	self:calc_3d_map(pos)
	result.volume = self:get_result_size()
	result.ptr = ffiopt.ffi.cast('float*', self:get_result_ptr())
	setmetatable(result, result_metatable)
	return result
end

minetest.after(0, function()
	local mt = getmetatable(minetest.get_perlin_map({ offset = 0, scale = 1,
			spread = {x=16, y=16, z=16}, seed = 0, octaves = 1, persist = 0 },
		{x = 16, y = 16, z=16}))
	if not mt['get_result_ptr'] then
		minetest.log("warning", string.format("[%s] No optimisation for PerlinMap, missing get_result_ptr method.",
			ffiopt.name))
	end
	if not mt['get_result_size'] then
		minetest.log("warning", string.format("[%s] No optimisation for PerlinMap, missing get_result_size method.",
			ffiopt.name))
	end
	if mt['get_result_ptr'] and mt['get_result_size'] then
		minetest.log("action", string.format("[%s] PerlinMap can be optimized.",
			ffiopt.name))
		mt['get2dMap_flat'] = get2dMap_flat
		mt['get3dMap_flat'] = get3dMap_flat
	end
end)
