local BASE_DIR
if minetest then
   local LOADING_MOD = minetest.get_current_modname()
   BASE_DIR = minetest.get_modpath(LOADING_MOD)
else
   BASE_DIR = os.getenv("PWD")
end

local ModLib = dofile(BASE_DIR.."/lib/ModLib.lua")

local verA = ModLib.Version("1")
local verB = ModLib.Version("1.0")
local verC = ModLib.Version("1.0.0.3")
local verD = ModLib.Version("1.1")
local verE = ModLib.Version("2.0")

assert("1" == tostring(verA))
assert("1" == tostring(verB))
assert("1.0.0.3" == tostring(verC))
assert("1.1" == tostring(verD))
assert("2" == tostring(verE))

assert(verA == verB)
assert(verB < verC)
assert(verC < verD)
assert(verD < verE)

assert(verA <= verB)
assert(verB <= verC)
assert(verC <= verD)
assert(verD <= verE)

assert("0" == tostring(ModLib.Version("0.0.0")))
assert("0.1" == tostring(ModLib.Version("0.1")))

local verF = ModLib.Version("3.14")
local verG = ModLib.Version("3.4")

assert(verG < verF)

print("ModLib.Version tests PASSED")
