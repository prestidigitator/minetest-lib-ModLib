local BASE_DIR
if minetest then
   local LOADING_MOD = minetest.get_current_modname()
   BASE_DIR = minetest.get_modpath(LOADING_MOD)
else
   BASE_DIR = os.getenv("PWD")
end

local ModLib = dofile(BASE_DIR.."/lib/ModLib.lua")
ModLib.addDir(BASE_DIR.."/lib")
ModLib.addDir(BASE_DIR.."/test/lib")

assert(not pcall(ModLib.load, "Zoog"))

local MyLib1 = ModLib.load("MyLib", "1", "1")
local MyLib1b = ModLib.load("MyLib", "1.0", "1.0")

assert(MyLib1)
assert(MyLib1b)
assert(MyLib1 == MyLib1b)
assert("1" == MyLib1.VERSION)
assert("1.0" == MyLib1.v)

local MyLib1_1 = ModLib.load("MyLib", "1.1", "1.1")

assert(MyLib1_1)
assert(MyLib1_1 ~= MyLib1)
assert("1.1" == MyLib1_1.VERSION)
assert("1.1" == MyLib1_1.v)

local MyLib2 = ModLib.load("MyLib", "2.0.0.0.0.0", "2")

assert(MyLib2)
assert(MyLib2 ~= MyLib1)
assert(MyLib2 ~= MyLib1_1)
assert("2" == MyLib2.VERSION)
assert("2.0.0" == MyLib2.v)

local MyLib2_0_5 = ModLib.load("MyLib", "2.0.5", "2.0.5")

assert(MyLib2_0_5)
assert(MyLib2_0_5 ~= MyLib1)
assert(MyLib2_0_5 ~= MyLib1_1)
assert(MyLib2_0_5 ~= MyLib2)
assert("2.0.5" == MyLib2_0_5.VERSION)
assert("2.0.5" == MyLib2_0_5.v)

local MyLib_any = ModLib.load("MyLib")

assert(MyLib_any)
assert(MyLib_any == MyLib2_0_5)

local MyLib_min0_5 = ModLib.load("MyLib", "0.5")
local MyLib_min1_0_5 = ModLib.load("MyLib", "1.0.5")
local MyLib_min1_5 = ModLib.load("MyLib", "1.0.5")
local MyLib_min2 = ModLib.load("MyLib", "2")
assert(not pcall(ModLib.load, "MyLib", "3"))

assert(MyLib_min0_5)
assert(MyLib_min1_0_5)
assert(MyLib_min1_5)
assert(MyLib_min2)
assert(MyLib_min0_5 == MyLib2_0_5)
assert(MyLib_min1_0_5 == MyLib2_0_5)
assert(MyLib_min1_5 == MyLib2_0_5)
assert(MyLib_min2 == MyLib2_0_5)

assert(not pcall(ModLib.load, "MyLib", nil, "0.5"))
local MyLib_max1 = ModLib.load("MyLib", nil, "1")
local MyLib_max1_0_1 = ModLib.load("MyLib", nil, "1.0.1")
local MyLib_max1_1 = ModLib.load("MyLib", nil, "1.1")
local MyLib_max1_5 = ModLib.load("MyLib", nil, "1.5")
local MyLib_max2 = ModLib.load("MyLib", nil, "2")
local MyLib_max3 = ModLib.load("MyLib", nil, "3")

assert(MyLib_max1 == MyLib1)
assert(MyLib_max1_0_1 == MyLib1)
assert(MyLib_max1_1 == MyLib1_1)
assert(MyLib_max1_5 == MyLib1_1)
assert(MyLib_max2 == MyLib2)
assert(MyLib_max3 == MyLib2_0_5)

assert(not pcall(ModLib.load, "MyLib", "2", "1"))
local MyLib_1_to_2 = ModLib.load("MyLib", "1", "2")
local MyLib_1_1_to_2 = ModLib.load("MyLib", "1.1", "2")
local MyLib_2_to_3 = ModLib.load("MyLib", "2", "3")
assert(not pcall(ModLib.load, "MyLib", "2.5", "3"))

assert(MyLib_1_to_2)
assert(MyLib_1_to_2 == MyLib2)
assert(MyLib_1_1_to_2 == MyLib2)
assert(MyLib_2_to_3 == MyLib2_0_5)

print("ModLib tests PASSED")
