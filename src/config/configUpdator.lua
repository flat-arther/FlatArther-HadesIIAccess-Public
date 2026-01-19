-- This is to replace entries for which the defaults have changed, without replacing the entire config.cfg file. Only works on versions greator than that of the user's
local migrations = {
    [0.2] = {
        ["AccessDisplay.LongInfoArray"] = {"Dist", "Armor", "Health", "Mana", "LastStand", "Gold", "DoorInfo", "ItemInfo", "WeaponInfo", "GardenInfo", "Anim", "Effects", "Description" },
    },
}

local function set_nested_value(root, path, value)
    local keys = {}
    for key in string.gmatch(path, "([^.]+)") do
        
        table.insert(keys, key)
    end

    local current = root
    for i = 1, #keys - 1 do
        local k = keys[i]
        if current[k] == nil then current[k] = {} end
        current = current[k]
    end
    
    current[keys[#keys]] = value
end

local sorted_versions = {}
    for v in pairs(migrations) do table.insert(sorted_versions, v) end
    table.sort(sorted_versions)
local target_version = sorted_versions[#sorted_versions]
if target_version > raw_user_config_version then
    
    for _, v in ipairs(sorted_versions) do
        -- Only apply changes that are newer than the user's current version
        if v > raw_user_config_version and v <= target_version then
            for path, newValue in pairs(migrations[v]) do
                set_nested_value(config, path, newValue)
            end
        end
    end

    config.version = target_version
    -- Update the user's version number so this doesn't run again
end
