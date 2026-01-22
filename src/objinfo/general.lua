local M = {}

local animation = import 'objinfo/animationHelpers.lua'
local effectHelpers = import 'objinfo/effectHelpers.lua'
import 'data/replacementNames.lua'

local SCALE_FACTOR = config.TrackingBeaconGlobal.ScaleFactor or 100.0
function M.GetGardenPlotInfo(id)
    local plot = GameState.GardenPlots and GameState.GardenPlots[id]
    if not plot then return nil end

    local parts = {}

    for i, plotId in ipairs(GardenData.PlotOrder) do
        if plotId == id then
            table.insert(parts, "Plot " .. i)
            break
        end
    end

    if not plot.SeedName then
        table.insert(parts, "Empty")
    else
        local plantName = GetDisplayName({ Text = plot.SeedName })
        table.insert(parts, plantName)

        if plot.ReadyForHarvest then
            table.insert(parts, "Ready to harvest")
        else
            local time = plot.GrowTimeRemaining or 0
            local unit = (time == 1) and "encounter" or "encounters"
            table.insert(parts, time .. " " .. unit .. " remaining")
        end
    end

    return table.concat(parts, " - ")
end

function M.GetWeaponInfo(id)
    local weapon = MapState.WeaponKits and MapState.WeaponKits[id]
    if not weapon then return nil end
    local parts = {}
    if IsBonusUnusedWeapon(weapon.Name) then
        table.insert(parts, "(" .. GetDisplayName({ Text = "UnusedWeaponBonusTrait" }) .. ")")
    end

    return table.concat(parts, " - ")
end

function M.GetItemInfo(Id, showDetails)
    local item = (MapState.ActiveObstacles and MapState.ActiveObstacles[Id]) or (LootObjects and LootObjects[Id])
    if not item then return nil end
    if showDetails == nil then showDetails = false end 

    local parts = {}
local rawName = GetName({ Id = Id})
    if item.ResourceCosts then
        local costStrings = {}
        for resourceName, resourceAmount in pairs(item.ResourceCosts) do
            if resourceAmount > 0 then
                local resourceDisplay = GetDisplayName({ Text = resourceName, IgnoreIcons = true })
                table.insert(costStrings, resourceAmount .. " " .. resourceDisplay)
            end
        end
        if #costStrings > 0 then
            table.insert(parts, "Cost: " .. table.concat(costStrings, ", "))
        end
    end

    if item.RewardType then
        table.insert(parts, GetDisplayName({ Text = item.RewardType}))
    end
    
    if GetName({ Id = item.ObjectId}) == "FieldsRewardCage" then
        local cageReward = item.RewardId
        
        if cageReward then
            local displayName = GetDisplayName({ Text = GetName({ Id = cageReward}), IgnoreIcons = true })
            table.insert(parts,  "Reward: " .. displayName)
        else
            table.insert(parts, "Empty Cage")
        end
    end

    if GameState.StoreItemPins then
        for _, pinName in pairs(GameState.StoreItemPins) do
            if pinName == rawName then
                table.insert(parts, "[Pinned]")
                break
            end
        end
    end

    if HasActiveQuestForName(rawName) then
        table.insert(parts, "[Prophecy]")
    end

    if item.InteractBlocks and not IsEmpty(item.InteractBlocks) then
        table.insert(parts, GetDisplayName({ Text = "AwardMenuLocked" }))
    end
    if #parts == 0 then return nil end

    return table.concat(parts, " - ")
end

-- Thanks to Lirin and his Blind_Accessibility mod for parts of the following function: https://github.com/Lirin111/Hades2BlindAccessibility
function M.GetDoorInfo(Id, showDetails)
    if showDetails == nil then showDetails = false end

    local door = MapState.OfferedExitDoors and MapState.OfferedExitDoors[Id]
    local wheel = MapState.ShipWheels and MapState.ShipWheels[Id]
    local exit = door or wheel

    if not exit then return nil end

    local parts = {}
    local rewardNames = {}
    local room = exit.Room
    if not room then return GetDisplayName({ Text = "AwardMenuLocked" }) end

    local encounter = exit.Encounter or room.Encounter

    local function CleanName(text)
        if not text then return "Unknown" end
        if text == "ElementalBoost" then return "Boon_Infusion" end
        if string.match(text, "Mixer.*Drop") then text = text:gsub("Drop", "") end

        return GetDisplayName({ Text = text, IgnoreIcons = true })
            :gsub("Upgrade", "")
            :gsub("Drop", "")
            :gsub("Room", "")
            :gsub("Progress", "")
            :gsub("Run", "")
    end

    local reward = (encounter and encounter.RewardType) or exit.ChosenRewardType or room.ChosenRewardType
    local isHidden = exit.HideRewardPreview or HasHeroTraitValue("HiddenRoomReward")

    if isHidden then
        table.insert(parts, "reward hidden")
    else
        if exit.Name == "EphyraExitDoorReturn" or (exit.ReturnToPreviousRoomName == "N_Hub") then
            table.insert(parts, GetDisplayName({ Text = "BiomeN" }))
        elseif exit.RewardPreviewAnimName == "ShopPreview" then
            local shopText = GetDisplayName({ Text = "UseStore" }):gsub("{[^}]*}", "")
            table.insert(parts, shopText)
        elseif room then
            if (room.Name:find("Story") or room.Name:find("Reprieve")) then
                local npcName = (reward == "Story") and "Story Encounter" or "Reprieve"
                table.insert(parts, npcName)
            end
            if room.CageRewards then
                for _, cageReward in ipairs(room.CageRewards) do
                    table.insert(rewardNames, cageReward.ForceLootName or cageReward.RewardType)
                end
            elseif reward == "Devotion" and encounter then
                if encounter.LootAName then table.insert(rewardNames, encounter.LootAName) end
                if encounter.LootBName then table.insert(rewardNames, encounter.LootBName) end
            else
                local rName = nil

                if CurrentRun.CurrentRoom.OfferedRewards and CurrentRun.CurrentRoom.OfferedRewards[Id] then
                    local offData = CurrentRun.CurrentRoom.OfferedRewards[Id]
                    rName = offData.ForceLootName or offData.Type
                elseif encounter and (encounter.LootName or encounter.ForceLootName) then
                    rName = encounter.LootName or encounter.ForceLootName
                elseif reward == "Loot" then
                    rName = exit.ForceLootName or room.ForceLootName or "Loot"
                else
                    rName = reward
                end

                if rName then table.insert(rewardNames, rName) end
            end
        end

        for _, rawName in ipairs(rewardNames) do
            if rawName then
                local clean = CleanName(rawName)
                local details = {}

                if showDetails then
                    if GameState.StoreItemPins then
                        for _, pinName in pairs(GameState.StoreItemPins) do
                            if pinName == rawName then
                                table.insert(details, "pinned")
                                break
                            end
                        end
                    end
                    if HasActiveQuestForName(rawName) then
                        table.insert(details, "prophecy")
                    end
                end

                if #details > 0 then
                    clean = clean .. " (" .. table.concat(details, ", ") .. ")"
                end
                table.insert(parts, "leads to " .. clean)
            end
        end
    end

    if room or encounter then
        local args = { RoomData = room or CurrentRun.CurrentRoom }
        local rewardOverrides = args.RoomData.RewardOverrides or {}
        local previewIcon = rewardOverrides.RewardPreviewIcon or (encounter and encounter.RewardPreviewIcon) or
        args.RoomData.RewardPreviewIcon

        if previewIcon then
            if previewIcon == "RoomRewardSubIcon_Boss" or previewIcon == "RoomElitePreview4" then
                table.insert(parts, GetDisplayName({ Text = "Boss" }))
            elseif previewIcon == "RoomRewardSubIcon_Miniboss" or previewIcon == "RoomElitePreview2" then
                table.insert(parts, GetDisplayName({ Text = "MiniBoss" }))
            elseif previewIcon == "RoomElitePreview3" then
                table.insert(parts, "Infernal Gate")
            else
                table.insert(parts, "Elite")
            end
        end

        if encounter and encounter.EncounterType == "Challenge" then
            local alreadyAdded = false
            for _, p in ipairs(parts) do if p == "Infernal Gate" then
                    alreadyAdded = true; break
                end end
            if not alreadyAdded then table.insert(parts, "Infernal Gate") end
        end
    end

    if exit.HealthCost and exit.HealthCost ~= 0 then
        table.insert(parts, "Costs " .. math.abs(exit.HealthCost) .. " Health")
    end

    if exit.EncounterCost then
        table.insert(parts, "Sealed by encounter")
    end

    if rewardNames[1] == "ClockworkGoal" and CurrentRun.RemainingClockworkGoals then
        table.insert(parts, "(" .. CurrentRun.RemainingClockworkGoals .. " remaining)")
    end

    if #parts == 0 then return "Exit" end
    return table.concat(parts, ", ")
end

function M.GetUnitManaString(id)
    local unit = ActiveEnemies[id]
    if CurrentRun and CurrentRun.Hero and id == CurrentRun.Hero.ObjectId then
        unit = CurrentRun.Hero
    end
    if not unit then return nil end
    local mana = nil
    if unit.Mana and unit.MaxMana then
            mana = unit.Mana .. " of " .. unit.MaxMana .. " magic"
        end

    return mana
end

function M.GetUnitArmorString(id)
    local unit = ActiveEnemies[id]
    if CurrentRun and CurrentRun.Hero and id == CurrentRun.Hero.ObjectId then
        unit = CurrentRun.Hero
    end
    if not unit then return nil end
    local armor = nil
    if unit.HealthBuffer and unit.HealthBuffer > 0 then
        armor = unit.HealthBuffer .. " armor"
    end
    return armor
end

function M.GetUnitHealthString(Id, Percentage, Short)
    if not Id then return nil end

    if Percentage == nil then Percentage = false end
    if Short == nil then Short = config.AccessDisplay.ShortenHealthStrings or false end

    local unit = ActiveEnemies[Id]
    if CurrentRun and CurrentRun.Hero and Id == CurrentRun.Hero.ObjectId then
        unit = CurrentRun.Hero
    end

    if not unit or not unit.Health or not unit.MaxHealth then
        return nil
    end

    if unit.HideHealthBar then return "health hidden" end
    local suffix = ""
    if not Short then
        suffix = " health"
    end

    if Percentage then
        local hpPercent = math.floor((unit.Health / unit.MaxHealth) * 100)
        return hpPercent .. " percent" .. suffix
    end

    return math.floor(unit.Health) .. " of " .. math.floor(unit.MaxHealth) .. suffix
end

function M.GetHeroMoneyString()
if not CurrentRun or not CurrentRun.Hero then return nil end
local currentMoney = GetResourceAmount("Money")
if currentMoney > 0 then
    return currentMoney .. " " .. GetDisplayName({ Text = "Currency", IgnoreIcons = true })
end
return nil
end

function M.GetHeroLastStandString()
    if not CurrentRun or not CurrentRun.Hero then
        return ""
    end

    local hero = CurrentRun.Hero

    if SessionMapState and SessionMapState.InfiniteDeathDefiance then
        return "Unlimited death defiances"
    end

    local count = hero.LastStands and #hero.LastStands or 0
    if count == 0 then
        return "No death defiances"
    end

    if count == 1 then
        return "1 death defiance"
    end

    return tostring(count)
        .. " of "
        .. tostring(hero.MaxLastStands or count)
        .. " death defiances"
end

function M.GetDescriptionInfo(id)
    if not CurrentRun or not CurrentRun.Hero then return nil end
    local Hero = CurrentRun.Hero
    local unit = ActiveEnemies[id]
    if id == Hero.ObjectId then unit = Hero end

    local obstacle = (MapState.ActiveObstacles and MapState.ActiveObstacles[id]) or (LootObjects and LootObjects[id])
    local door = (MapState.OfferedExitDoors and MapState.OfferedExitDoors[id]) or (MapState.ShipWheels and MapState.ShipWheels[id])
    local weapon = MapState.WeaponKits and MapState.WeaponKits[id]
    local gardenPlot = GameState.GardenPlots and GameState.GardenPlots[id]
    local object = unit or obstacle or door or weapon
    if not object then
        return nil
    end

local description = nil

    if not description and CodexData then
        local keys = {}
        table.insert(keys, GetName({ Id = object.ObjectId }))
        if object.Name then table.insert(keys, object.Name) end
        if object.GenusName and object.GenusName ~= object.Name then
            table.insert(keys, object.GenusName)
        end

        for _, key in ipairs(keys) do
            for _, chapter in pairs(CodexData) do
                local entry = chapter.Entries and chapter.Entries[key]
                if entry and entry.Entries then
                    for _, sub in ipairs(entry.Entries) do
                        local unlocked =
                            (SessionState and SessionState.CodexDebugUnlocked)
                            or sub.UnlockGameStateRequirements == nil
                            or IsGameStateEligible(
                                CurrentRun,
                                sub.UnlockGameStateRequirements
                            )

                        if unlocked and sub.Text then
                            description = GetDisplayName({ Text = sub.Text })
                            break
                        end
                    end
                end
                if description then break end
            end
            if description then break end
        end
    end

    if description then
        description = description :gsub("{.-}", "") :gsub("\\n", " ")
    end
return description
end


-- This helper function is credited to Lirin from his Blind_Accessibility mod: https://github.com/Lirin111/Hades2BlindAccessibility
local function GetChallengeDisplayName(rawName)
    if not rawName then
        return "ChallengeSwitch"
    end

    -- Strip reward suffix (anything after first underscore)
    local baseName = string.match(rawName, "^(%a+ChallengeSwitch)") or "ChallengeSwitch"

    -- Map internal base names to the game’s localization IDs
    local locMap = {
        TimeChallengeSwitch = "ChallengeSwitch",               -- Infernal Trove
        EliteChallengeSwitch = "EliteChallengeSwitch",         -- Moon Monument
        PerfectClearChallengeSwitch = "PerfectClearChallengeSwitch", -- Unseen Sigil
    }

    local locId = locMap[baseName] or "ChallengeSwitch"

    -- Return localized text
    return GetDisplayName({ Text = locId, IgnoreSpecialFormatting = true })
end


-- Mostly here to handle edgecases
function M.GetObjectName(id)
    local name = GetName({ Id = id })
    if string.find(name, "Mixer.*Drop") then
        name = name:gsub("Drop", "")
    end
    if string.find(name, "^HealthFountain") then
        name = "Fountain"
    end
    if string.find(name, "^Breakable_.$") then
        name = "Breakable obstacle"
    end
    if CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.WellShop and id == CurrentRun.CurrentRoom.WellShop.ObjectId then
        name = "WellShop_Title"
    elseif CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.SurfaceShop and id == CurrentRun.CurrentRoom.SurfaceShop.ObjectId then
        name = "SurfaceShop_Title"
    elseif CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.SellTraitShop and id == CurrentRun.CurrentRoom.SellTraitShop.ObjectId then
        name = "SellTraitShop"
    elseif CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.MetaRewardStand and id == CurrentRun.CurrentRoom.MetaRewardStand.ObjectId then
        name = "ShrinePointReward"
    elseif CurrentRun and CurrentRun.CurrentRoom and CurrentRun.CurrentRoom.ChallengeSwitch and id == CurrentRun.CurrentRoom.ChallengeSwitch.ObjectId then
        name = GetChallengeDisplayName(CurrentRun.CurrentRoom.ChallengeSwitch.Name)
    elseif name == "WeaponKit01" then
        name = MapState.WeaponKits[id].Name
    elseif name == "FamiliarKit" then
        name = (MapState.FamiliarKits and MapState.FamiliarKits[id].Name) or name
    elseif string.find(name, "_Chronos0") and not IsGameStateEligible(ActiveEnemies[id], { { PathTrue = { "GameState", "EncountersOccurredCache", "GeneratedAnomalyB" } } }) then
        name = "Speaker_Anonymous"
    else
        if ReplacementNames[name] then
            name = ReplacementNames[name]
        end
    end
    return name
end

function M.SummarizeUnitInfo(id, long)
    if not id or not CurrentRun or not CurrentRun.Hero then
        return ""
    end
    if long == nil then
        long = false
    end
    local heroId = CurrentRun.Hero.ObjectId
local ls = nil
    local hp = nil
    local unitDistance = nil
    local money = nil
        if id == heroId then
            ls = M.GetHeroLastStandString()
            hp = M.GetUnitHealthString(id)
            money = M.GetHeroMoneyString()
        else
            hp = M.GetUnitHealthString(id, true)
            unitDistance = tostring(math.floor(GetDistance({ Id = CurrentRun.Hero.ObjectId, DestinationId = id }) / (SCALE_FACTOR or 100))) .. " units away"
        end

    local IgnoreIcons = true

    if hp then IgnoreIcons = false end
    local objName = M.GetObjectName(id)
    local info = {
        Name = GetDisplayName({ Text = objName, IgnoreIcons = IgnoreIcons }) or "Unknown",
        Armor = M.GetUnitArmorString(id),
        Health = hp,
        Mana = M.GetUnitManaString(id),
        LastStand = ls,
        Gold = money,
        Dist = unitDistance,
        Anim = animation.GetAnimation({ Id = id, TranslatedOnly = true }),
        Effects = effectHelpers.GetEffectsString(id, long, long),
        DoorInfo = M.GetDoorInfo(id, false),
        ItemInfo = M.GetItemInfo(id, false),
        WeaponInfo = M.GetWeaponInfo(id),
        GardenInfo = M.GetGardenPlotInfo(id),
        Description = M.GetDescriptionInfo(id),
    }

    local order = nil
if long then
    order = (config and config.AccessDisplay and config.AccessDisplay.LongInfoArray)
else
    order = (config and config.AccessDisplay and config.AccessDisplay.InfoArray)
end

order = order or { "DoorInfo", "Name", "GardenInfo", "ItemInfo", "WeaponInfo", "Armor", "Health", "Dist", "Anim", "Effects", "Description" }
    local parts = {}

    for _, key in ipairs(order) do
        local value = info[key]
        if value and value ~= "" then
            local str = tostring(value)

            if #parts > 0 then
                local sep = ", "
                if key == "Health" then
                    sep = " at "
                elseif key == "Dist" then
                    sep = ": "
                elseif key == "Name" then
                    sep = " "
                end
                str = sep .. str
            end

            table.insert(parts, str)
        end
    end
if #parts > 0 then
    return table.concat(parts)
else
    return "No information found"
end
end

return M