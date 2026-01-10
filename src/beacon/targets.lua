local M = {}
local info = import 'objinfo/general.lua'
import 'data/StaticIdDisplayNames.lua'
local BeaconCategoryTables = config.TrackingBeaconTargetCategories or {}
local beaconCategories = config.AccessDisplay.CategoriesArray or
    { "EnemyTeam", "NPCs", "Interactibles", "ConsumableItems", "Loot", "HeroTeam", "DestructibleGeo", "Traps", "Familiars", "ExitDoors", }


local TargetBasePriority = config.BeaconTargetWeights or {
    Unit = 3.5,
    Door = 2.5,
    Loot = 3.0,
    Obstacle = 2.0,
    Weapon = 1.6,
    Familiar = 1.2,
}

function M.GetCategory(name)
    local catList = M.GetAllCategories()
    for i, catName in ipairs(catList) do
        if catName == name then
            return { Index = i, Cfg = BeaconCategoryTables[catName] }
        end
    end
    return nil
end

function M.GetAllCategories()
    return beaconCategories, BeaconCategoryTables
end

local function ResolveCategoryConfig(currentIndex)
    -- index 0 = all categories
    if currentIndex == 0 then
        return {
            Names = beaconCategories,
            Config = {
                IgnoreInvulnerable = false,
                IgnorePermanentlyInvulnerable = false,
                IgnoreHomingIneligible = false,
                IgnoreSelf = true,
                StopsProjectiles = false,
                StopsUnits = false,
                DestinationTypes = {"WeaponKit01", "FamiliarKit", "ShipWheels", "NightMirror", "HadesFountain", "WitchHut", "PalaceForcefield"},
            }
        }
    end

    local key = beaconCategories[currentIndex]
    local cfg = BeaconCategoryTables[key] or {}

    local catList = {}
    catList[key] = true

    if cfg.LinkedCategories then
        for _, linked in ipairs(cfg.LinkedCategories) do
            catList[linked] = true
        end
    end

    return {
        Names = KeysToList(catList),
        Config = cfg
    }
end

function M.GetBeaconTargets(currentIndex)
    if not CurrentRun or not CurrentRun.Hero then return {} end
    local heroId = CurrentRun.Hero.ObjectId
    local res = ResolveCategoryConfig(currentIndex or 0)
    local cfg = res.Config or {}
    local ShipWheels = MapState and MapState.ShipWheels and KeysToList(MapState.ShipWheels)
    local destinationIds = nil
    if cfg.DestinationTypes and #cfg.DestinationTypes > 0 then
        destinationIds = GetIdsByType({ Names = cfg.DestinationTypes })
    end

    local targets = GetClosestIds({
        Id = heroId,
        DestinationNames = res.Names,
        DestinationIds = destinationIds,
        IgnoreInvulnerable = cfg.IgnoreInvulnerable,
        IgnorePermanentlyInvulnerable = cfg.IgnorePermanentlyInvulnerable,
        IgnoreHomingIneligible = cfg.IgnoreHomingIneligible,
        IgnoreSelf = cfg.IgnoreSelf ~= false,
        StopsProjectiles = cfg.StopsProjectiles,
        StopsUnits = cfg.StopsUnits,
        Distance = 9999,
    })
    -- Todo: Move this to its own function later
    if not IsEmpty(ShipWheels) and Contains(cfg.DestinationTypes, "ShipWheels") then
        for _, id in pairs(ShipWheels) do
            if GetName({ Id = id}) == "ShipsSteeringWheel" then goto continue end
            TolkSpeak(id)
            table.insert(targets, id)
            ::continue::
        end
    elseif Contains(cfg.DestinationTypes, "NightMirror") and IdExists({ Id = 741588}) and IsUseable({ Id = 741588}) then
        table.insert(targets, 741588)
        elseif Contains(cfg.DestinationTypes, "PastZag") and IdExists({ Id = 772206}) then
            --table.insert(targets, 772206)
        elseif Contains(cfg.DestinationTypes, "HadesFountain") and IdExists({ Id = 742624}) and IsUseable({ Id = 742624}) then
            table.insert(targets, 742624)
        elseif Contains(cfg.DestinationTypes, "HotSprings") and IdExists({ Id = 589481}) and IsUseable ( { Id = 589481}) then
            table.insert(targets, 589481)
            elseif Contains(cfg.DestinationTypes, "WitchHut") and IdExists({ Id = 744068}) and IsUseable ( { Id = 744068}) then
            table.insert(targets, 744068)
            elseif Contains(cfg.DestinationTypes, "PalaceForcefield") and IdExists({ Id = 792642}) then
                table.insert(targets, 792642)
    end
    for i = #targets, 1, -1 do
        
        if not M.IsValidBeaconTarget(targets[i]) then
            table.remove(targets, i)
        end
    end


    if config.TrackingBeaconGlobal.SortByScore then
        targets = SortByScore(targets)
    else
        targets = SortByClosest(targets)
    end
    return targets
end

-- Target cicling
function M.GetNextBeaconTarget(direction, catIndex)
    if catIndex == nil then catIndex = beaconState.categoryIndex end
    local targetList = M.GetBeaconTargets(catIndex)

    if #targetList == 0 then
        return nil, nil, targetList
    end

    local newIndex = 1

    if direction ~= 0 then
        local found = false

        if beaconState.lastTargetId and IdExists({ Id = beaconState.lastTargetId }) then
            for i, entry in ipairs(targetList) do
                if entry.Id == beaconState.lastTargetId then
                    newIndex = i
                    found = true
                    break
                end
            end
        end

        if not found and beaconState.lastTargetIndex then
            if beaconState.lastTargetIndex >= 1 and beaconState.lastTargetIndex <= #targetList then
                newIndex = beaconState.lastTargetIndex
                found = true
            end
        end

        if beaconState.targetId then
            newIndex = newIndex + direction

        end

        if newIndex > #targetList then newIndex = 1 end
        if newIndex < 1 then newIndex = #targetList end
    end
    return targetList[newIndex].Id, newIndex, targetList
end

function M.SetBeaconTarget(id, index, resetExistingTarget)
    if not id then
        return false
    end
    if resetExistingTarget == nil then resetExistingTarget = true end
    if not resetExistingTarget and id == beaconState.targetId then return false end
    beaconState.targetId = id
    beaconState.lastTargetId = id
    beaconState.targetIndex = index
    beaconState.lastTargetIndex = index
    return true
end

-- Target priority
function M.ClassifyTarget(id)
    if not id then return nil end
    if CurrentRun and CurrentRun.Hero and id == CurrentRun.Hero.ObjectId then
        return "Hero"
    end
    if UnitSetData.Traps[GetName({ Id = id })] then
        return "Trap"
    end
    if ActiveEnemies and ActiveEnemies[id] then
        return "Unit"
    end
    if LootObjects and LootObjects[id] then
        return "Loot"
    end
    if MapState then
        if MapState.OfferedExitDoors and MapState.OfferedExitDoors[id] then
            return "Door"
        end
        if MapState.ShipWheels and MapState.ShipWheels[id] then
            return "Door"
        end
        if MapState.WeaponKits and MapState.WeaponKits[id] then
            return "Weapon"
        end
        if MapState.FamiliarKits and MapState.FamiliarKits[id] then
            return "Familiar"
        end
        if MapState.ActiveObstacles and MapState.ActiveObstacles[id] then
            if LootData[GetName({ Id = id })] then
                return "Loot"
            else
                return "Obstacle"
            end
        end
    end
    return "Unknown"
end

-- Utility functions to check if targets should be added to the list

function M.IsValidBeaconTarget(id)
    if not id then return false end
    if id ~= 590506 and StaticIdDisplayNames[id] then return true end
    local obstacle = (MapState.ActiveObstacles and MapState.ActiveObstacles[id]) or (LootObjects and LootObjects[id])
    local door = (MapState.OfferedExitDoors and MapState.OfferedExitDoors[id]) or
        (MapState.ShipWheels and MapState.ShipWheels[Id])
    local weapon = MapState.WeaponKits and MapState.WeaponKits[id]
    local familiar = MapState.FamiliarKits and MapState.FamiliarKits[id]
    local unit = ActiveEnemies and ActiveEnemies[id]
    local object = unit or obstacle or door or weapon or familiar
    if not object then return false end
    if familiar then
        if object.Name ~= GameState.EquippedFamiliar then
            return false
        end
    end
    if weapon then
        local weaponName = weapon.Name
        if not IsWeaponUnlocked(weaponName) or GetEquippedWeapon() == weaponName then
            return false
        end
    end
    if unit then
        if (unit.OnUsedFunctionName and #unit.OnUsedFunctionName > 0) and not IsUseable({ Id = object.ObjectId }) and unit.Mute then
            return false
        end
    end
    if obstacle and not door then
        if obstacle.ObjectId == 590506 then
            return IsGameStateEligible(obstacle, { { PathTrue = { "GameState", "WorldUpgradesAdded", "WorldUpgradeTaverna" } } }, {})
        end
        if not obstacle.MaxHealth and not IsUseable({ Id = id }) then
            return false
        end
    end
    return true
end

function M.IsValidLivingUnit(unit)
    if not unit then return false end
    if not IsAlive({ Id = unit.ObjectId }) then return false end
    if unit.Health ~= nil and unit.Health <= 0 then return false end
    return true
end

return M
