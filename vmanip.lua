--[[
	ffiopt mod for Minetest - A mod for optimizing memory and speed of
	VoxelManip and PerlinNoiseMap
	(c) EvidenceBKidscode

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU Lesser General Public License as published
	by the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU Lesser General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

ffiopt.ffi.cdef[[
typedef struct MapData { uint16_t param0; uint8_t param1; uint8_t param2; } mapdata_t;
]]

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
	return data
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
