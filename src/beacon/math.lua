local M = {}

local beaconTargets = import 'beacon/targets.lua'

local BEACON_MIN_INTERVAL = (config.TrackingBeaconGlobal.MinInterval or 0.25)
local BEACON_MAX_INTERVAL = (config.TrackingBeaconGlobal.MaxInterval or 0.75)
local BEACON_MAX_DISTANCE = (config.TrackingBeaconGlobal.MaxDistance or 1200)

function M.ComputeBeaconInterval(rawDist)
    local ratio = rawDist / BEACON_MAX_DISTANCE
    return BEACON_MIN_INTERVAL + ratio * (BEACON_MAX_INTERVAL - BEACON_MIN_INTERVAL)
end

function M.GetFacingDotProduct(args)
    args = args or {}
    local isAlwaysNorth = args.IsAlwaysNorth or false
    
    if not CurrentRun or not CurrentRun.Hero then return 0 end
    if not args.TargetId and not args.AltAngle then return 0 end

    local heroId = CurrentRun.Hero.ObjectId
    local targetAngle = args.AltAngle or GetAngleBetween({ Id = heroId, DestinationId = args.TargetId })
    local playerAngle = isAlwaysNorth and 90 or (GetPlayerAngle() or GetAngle({ Id = heroId }))
    local delta = ((targetAngle - playerAngle + 180) % 360) - 180
    return math.cos(math.rad(delta))
end


-- Functions for scoring different object types:
function M.ScoreLoot(loot)
    local function IsGodEquivalentLoot(loot)
    if loot.GodLoot then
        return true
    end
                      
    if loot.SpeakerName == "Selene" then
        return true
    end

    -- Generic fallback
    if loot.BoonInfoTitleText ~= nil and loot.GoldConversionEligible then
        return true      
    end

    return false
end

    local score = 0
    if IsGodEquivalentLoot(loot) then score = score + 4 end
    if loot.Weight then score = score + loot.Weight / 10 end
    if loot.StackNum then score = score + loot.StackNum end
    if loot.LastRewardEligible then score = score + 0.5 end

if loot.ResourceCosts then
    for resourceName, cost in pairs(loot.ResourceCosts) do
        if cost > 0 then
        local owned = GetResourceAmount(resourceName) or 0
        local ratio = owned / cost

        if ratio >= 1 then
            score = score - cost * 0.01
        elseif ratio >= 0.5 then
            score = score - cost * 0.05
        else
            score = score - 10
        end
    end
    end
end

    return score
end

function M.GetHealthFraction()
    local hero = CurrentRun and CurrentRun.Hero
    if not hero or not hero.Health or not hero.MaxHealth then
        return 1
    end
    return hero.Health / hero.MaxHealth
end

function M.IsHealReward(name)
    return name
        and (
            string.find(name, "Heal") ~= nil
            or string.find(name, "Health") ~= nil
            or name == "LastStandDrop"
        )
end


function M.IsGodUpgrade(name)
    return name and string.find(name, "Upgrade") ~= nil
end

function M.ScoreDoor(door)
    local score = 0
    if not door or not door.Room then return -1 end
    if not door.ReadyToUse or not CheckRoomExitsReady(CurrentRun.CurrentRoom) or CheckSpecialDoorRequirement(door) ~= nil then return -1 end

    local room = door.Room
    local encounter = door.Encounter or room.Encounter
    local rewards = {}
    local healthFrac = M.GetHealthFraction()

    if door.HealthCost and door.HealthCost ~= 0 then
        score = score + (healthFrac * 3)
    end

    local rewardType = (encounter and encounter.RewardType) or door.ChosenRewardType or room.ChosenRewardType

    if room.CageRewards then
        for _, r in ipairs(room.CageRewards) do
            table.insert(rewards, r.ForceLootName or r.RewardType)
        end
    elseif rewardType == "Devotion" and encounter then
        if encounter.LootAName then table.insert(rewards, encounter.LootAName) end
        if encounter.LootBName then table.insert(rewards, encounter.LootBName) end
    else
        local rName = nil
        if CurrentRun.CurrentRoom.OfferedRewards and CurrentRun.CurrentRoom.OfferedRewards[door.ObjectId] then
            local offData = CurrentRun.CurrentRoom.OfferedRewards[door.ObjectId]
            rName = offData.ForceLootName or offData.Type
        elseif encounter and (encounter.LootName or encounter.ForceLootName) then
            rName = encounter.LootName or encounter.ForceLootName
        elseif rewardType == "Loot" then
            rName = door.ForceLootName or room.ForceLootName or "Loot"
        else
            rName = rewardType
        end

        if rName then table.insert(rewards, rName) end
    end

    for _, reward in ipairs(rewards) do
        if reward then
            if M.IsGodUpgrade(reward) then score = score + 3 end
            if reward == "WeaponUpgrade" then score = score + 3.5 end
            if reward == "StackUpgrade" then score = score + 3 end
            if reward == "TalentDrop" then score = score + 2.5 end
            if reward == "RoomMoneyDrop" then score = score + 1 end

            if M.IsHealReward(reward) then
                score = score + (1 - healthFrac) * 4
            end

            local loot = LootData and LootData[reward]
            if loot then
                score = score + M.ScoreLoot(loot)
            end

            if GameState.StoreItemPins and Contains(GameState.StoreItemPins, reward) then
                score = score + 8
            end
        end
    end

    local args = { RoomData = room or CurrentRun.CurrentRoom }
    local rewardOverrides = args.RoomData.RewardOverrides or {}
    
    local previewIcon = door.RewardPreviewIcon 
        or rewardOverrides.RewardPreviewIcon 
        or (encounter and encounter.RewardPreviewIcon) 
        or args.RoomData.RewardPreviewIcon

    if previewIcon then
        if previewIcon == "RoomRewardSubIcon_Boss" or previewIcon == "RoomElitePreview4" then
            score = score + 4
        elseif previewIcon == "RoomRewardSubIcon_Miniboss" or previewIcon == "RoomElitePreview1" or previewIcon == "RoomElitePreview2" then
            score = score + 3.5
        end
    end

    return score
end

function M.ScoreObstacle(obstacle)
    local score = 0
    if not obstacle then return score end

    local hero = CurrentRun and CurrentRun.Hero
    local healthFrac = hero and hero.Health and hero.MaxHealth and hero.Health / hero.MaxHealth or 1
local name = GetName({ Id = obstacle.ObjectId})
    if ConsumableData[name] then
        score = score + 10
    end
    
    if (string.find(name, "Shop") or string.find(name, "Switch")) and (obstacle.ReadyToUse or CheckRoomExitsReady( CurrentRun.CurrentRoom )) then
        score = score + 10
    end
    if name == "InspectPoint" then
        score = score + 2
    end
    if obstacle.HealFixed then
        score = score + obstacle.HealFixed * (1 - healthFrac) * 0.15
    end

    if obstacle.HealFraction then
        score = score + obstacle.HealFraction * (1 - healthFrac) * 6
    end

    if obstacle.AddMaxHealth then
        score = score + obstacle.AddMaxHealth * 0.2
    end

    if obstacle.AddMaxMana then
        score = score + obstacle.AddMaxMana * 0.15
    end

    if obstacle.AddArmor then
        score = score + obstacle.AddArmor * 0.12
    end

    if obstacle.AddTalentPoints then
        score = score + obstacle.AddTalentPoints * 1.2
    end

    if obstacle.AddRerolls then
        score = score + obstacle.AddRerolls * 1.5
    end

    if obstacle.AddResources then
        for _, amount in pairs(obstacle.AddResources) do
            score = score + amount * 0.05
        end
    end

    if obstacle.ReplaceWithRandomLoot then
        score = score + 2
    end


    if obstacle.LastRewardEligible then
        score = score + 0.5
    end

    if obstacle.HealthCost then
        local cost = type(obstacle.HealthCost) == "table"
            and obstacle.HealthCost.BaseMin or obstacle.HealthCost
        score = score - cost * healthFrac * 0.15
    end

    if obstacle.ResourceCosts then
    for resourceName, cost in pairs(obstacle.ResourceCosts) do
        if cost > 0 then
        local owned = GetResourceAmount(resourceName) or 0
        local ratio = owned / cost

        if ratio >= 1 then
            score = score - cost * 0.01
        elseif ratio >= 0.5 then
            score = score - cost * 0.05
        else
            score = score - 10
        end
    end
end
end
    if string.find(name, "Point$") then
    score = score + 7

    if obstacle.ToolName and not HasAccessToTool({ Tool = obstacle.ToolName}) then
        score = score - 9
    end

    if obstacle.AddResources then
        for name, amount in pairs(obstacle.AddResources) do
            if name:find("Plant") then
                score = score + amount * 0.8
            elseif name:find("Seed") then
                score = score + amount * 1.2
            elseif name == "MemPointsCommon" then
                score = score + amount * 0.5
            else
                score = score + amount * 0.05
            end
        end
    end
if CurrentRun.CurrentRoom and not CurrentRun.CurrentRoom.BlockCombat then
    if obstacle.ResourceName then
        score = score + 2
        if obstacle.MaxHealth then
            score = score + (3 - obstacle.MaxHealth) * 0.5
        end
    end
end

    if obstacle.HarvestPointName == "FishingPoint" then
        score = score + 2.5
    end

    if obstacle.AttemptsRemaining then
        score = score + obstacle.AttemptsRemaining * 0.4
    end
end
if obstacle.OnHitFunctionName and #obstacle.OnHitFunctionName > 0 then 
    score = score + 0.3
end

    if obstacle.InteractBlocks and not IsEmpty(obstacle.InteractBlocks) then
        score = score - 1.5
    end

    if obstacle.EnemiesBlockInteraction then
        score = score - 1
    end

    if not IsUseable({ Id = obstacle.ObjectId}) then
        score = score - 9
    end
    return score
end


function M.ScoreWeapon(weapon)
    if weapon and IsBonusUnusedWeapon(weapon.Name) then
        return 2
    end
    return 0.5
end

function M.ScoreUnit(unit)
    local score = 0
    if not beaconTargets.IsValidLivingUnit(unit) then return -1 end
    -- Make sure enemies are always rocketed up to the top of the list
    if unit.IsAggroed then score = score + 15 end
    if RequiredKillEnemies[unit.ObjectId] then score = score + 0.5 end
    if unit.MaxHealth and CurrentRun and CurrentRun.Hero and CurrentRun.Hero.MaxHealth then
        score = score + (unit.MaxHealth / CurrentRun.Hero.MaxHealth)
    end
    if unit.IsBoss then score = score + 3 end
    if unit.IsElite then score = score + 1.5 end
    if unit.HealthBuffer and unit.HealthBuffer > 0 then
        score = score + 0.5
    end
    if unit.Health and unit.MaxHealth then
        score = score + (1 - (unit.Health / unit.MaxHealth))
    end

    -- npcs
    
    if unit.NextInteractLines ~= nil then
        score = score + 4
    end
    if unit.StatusAnimations and unit.StatusAnimations.StatusIconWantsToTalkImportant then
        score = score + 4
    end
    if MapState and MapState.RoomRequiredObjects and MapState.RoomRequiredObjects[unit.ObjectId] then
        score = score + 4.5
    end
    if CanReceiveGift(unit) then
        score = score + 2.5
    end
    if unit.SpecialInteractFunctionName ~= nil then
        score = score + 1.0
    end
    if unit.ConversationThisRun then
        --score = score - 2.0
    end

    return score
end
return M
