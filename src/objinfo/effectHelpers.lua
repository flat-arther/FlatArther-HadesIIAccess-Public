-- Formats effect data / durations

import 'data/effects.lua'

local M = {}

function M.GetEffect(objectId, effect)
    if not objectId or not effect then return nil end

    local EffectData = {
        Name = effect,
        Duration = GetEffectTimeRemaining({ Id = objectId, EffectName = effect }) or 0,
        Desc = ""
    }

    if FriendlyEffectTranslations and FriendlyEffectTranslations[effect] then
        local t = FriendlyEffectTranslations[effect]
        EffectData.Name = t.Name or EffectData.Name
        EffectData.Desc = t.Description or ""
    else
        EffectData.Name = effect:gsub("Effect", ""):gsub("Stun", "")
    end

    return EffectData
end

function M.GetEffectString(objectId, effect, readDesc, readDuration)
    if readDesc == nil then readDesc = true end
    if readDuration == nil then readDuration = true end

    local ed = M.GetEffect(objectId, effect)
    if not ed then return "" end

    local s = ed.Name
    if readDuration and ed.Duration and ed.Duration > 0 then
        s = s .. " for " .. string.format("%.2f", ed.Duration) .. " seconds"
    end
    if readDesc and config.AccessDisplay.DescribeStatusEffects and ed.Desc and ed.Desc ~= "" then
        s = s .. ": " .. ed.Desc
    end
    return s
end

function M.GetEffectsString(id, readDesc, readDuration)
    if not id then return "" end

    local unit = ActiveEnemies[id]
    if CurrentRun and CurrentRun.Hero and id == CurrentRun.Hero.ObjectId then
        unit = CurrentRun.Hero
    end
    if not unit or not unit.ActiveEffects then return "" end

    if readDesc == nil then readDesc = true end
    if readDuration == nil then readDuration = true end

    local out = {}
    for effectName, _ in pairs(unit.ActiveEffects) do
        local s = M.GetEffectString(unit.ObjectId, effectName, readDesc, readDuration)
        if s and s ~= "" then table.insert(out, s) end
    end

    return table.concat(out, ", ")
end


return M
