FFIopt optimizes access to large amounts of data via the Lua API and reduces Lua memory footprint.

**License**: LGPL

# Description
Lua API methods that transmit large amount of data (VoxelManip:get_data, PerlinNoiseMap:get3dMap_flat) copies data from C++ structures to Lua tables. This copy is quite slow and consumes a lot of Lua memory.
FFIopt replaces this copy by a direct access from Lua to C++ data using FFI library. The engine has to be patched to expose some C++ pointers to Lua API.
If engine correctly patched, FFIopt hacks VoxelManip and PerlinNoiseMap to use FFI rather than Lua tables.

Result is :
- Faster data retreiving and storing ;
- Slower table access (essencially due to use of metatable avoiding mods code change) ;
- Lower Lua memory footprint (avoiding many OOM errors) ;

# How to use it
* Use LuaJIT.
* Patch the engine to add `VoxelManip:get_data_ptr`, `PerlinNoiseMap:get_result_size` and `PerlinNoiseMap:get_result_ptr` methods to the API.
* Install and enable ffiopt mod.
On starting Minetest, ffiopt will tell if it is able to optimise voxel manips and perlin noise.
* Nothing to change in mods code.

A successful log example:
```
2019-04-17 09:58:53: ACTION[Main]: [ffiopt] Using LUAJIT (version LuaJIT 2.0.3).
2019-04-17 09:58:53: ACTION[Main]: [ffiopt] FFI library loaded.
2019-04-17 16:19:44: ACTION[Server]: [ffiopt] PerlinMap can be optimized.
2019-04-17 16:19:44: ACTION[Server]: [ffiopt] VoxelManip can be optimized.
```
