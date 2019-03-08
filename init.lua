
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
