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

ffiopt = {}
ffiopt.name = minetest.get_current_modname()
ffiopt.path = minetest.get_modpath(ffiopt.name)

-- Load FFI Library
if type(jit) == 'table' then
	minetest.log("action", string.format("[%s] Using LUAJIT (version %s).",
		ffiopt.name, jit.version))
else
	minetest.log("warning", string.format(
		"[%s] Not using LUAJIT, FFI library may not load.", ffiopt.name))
end

local ie = minetest.request_insecure_environment()

if not ie then
	minetest.log("warning", string.format(
		"[%s] Could not get insecure environment, mod not listed in trusted_mods settings.",
		ffiopt.name))
else
	local status, err = pcall(function () ffiopt.ffi = ie.require 'ffi' end)
	if not status then
		minetest.log("warning", string.format("[%s] Cant load FFI library.",
			ffiopt.name))
	end
end

if not ffiopt.ffi then
	minetest.log("warning", string.format(
		"[%s] No optimisation will be provided.", ffiopt.name))
	return
end

minetest.log("action", string.format("[%s] FFI library loaded.", ffiopt.name))

dofile(ffiopt.path..'/vmanip.lua')
dofile(ffiopt.path..'/perlinnoise.lua')
