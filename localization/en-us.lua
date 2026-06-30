local nativefs = require("nativefs")
local lovely = require("lovely")

local mod_path = lovely.mod_dir .. "/Balatro-TripleSix"
local handy_loc = assert(load(nativefs.read(mod_path .. "/localization/handy.lua")))()
local fusion_loc = assert(load(nativefs.read(mod_path .. "/localization/fusion.lua")))()
local talisman_loc = assert(load(nativefs.read(mod_path .. "/localization/talisman.lua")))()

local function table_merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            table_merge(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

local merged = table_merge(handy_loc, fusion_loc)
return table_merge(merged, talisman_loc)
