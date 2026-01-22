local info = import 'objinfo/general.lua'

local M = {}

-- config
local BeaconCategoryTables = config.TrackingBeaconTargetCategories
local beaconCategories = config.AccessDisplay.CategoriesArray





------------------------------------------------------------
-- category cycling
------------------------------------------------------------

function M.CycleBeaconCategory(direction)

    local newIndex = (beaconState.categoryIndex + direction) % (#beaconCategories + 1)
    beaconState.categoryIndex = newIndex

    local label = "All"
    local cat = BeaconCategoryTables[beaconCategories[newIndex]]
    if newIndex > 0 then
        if not cat then 
            label = "Unconfigured category"
        else
        label = cat.DisplayName or "Unnamed category"
    end
end

    TolkSpeak(label, true)
end

------------------------------------------------------------
-- sound toggle
------------------------------------------------------------

function M.ToggleBeaconSound(args)
    local toggle = not config.TrackingBeaconGlobal.Toggle
    config.TrackingBeaconGlobal.Toggle = toggle
    TolkSpeak(toggle and "Beacon on" or "Beacon off")
end

------------------------------------------------------------
-- target cycling
------------------------------------------------------------
-- Cycle beacon target on enemy kills if already tracking
modutil.mod.Path.Wrap("KillEnemy", function(base, victim, triggerArgs)

    if not victim or not victim.MaxHealth or victim.MaxHealth <= 0 then base(victim, triggerArgs)
    return
    end
    local victimId = victim.ObjectId
    local wasTrackingVictim = (beaconState.lastTargetId ~= nil and beaconState.lastTargetId == victimId)

    if wasTrackingVictim then
        local category = beaconTargets.GetCategory("EnemyTeam")
        if category ~= nil then
            local id, index, targetList = beaconTargets.GetNextBeaconTarget(0, category.Index)
            if id then
                if not beaconTargets.SetBeaconTarget(id, index, false) then
                beaconState:ResetTarget()
                TolkSpeak("No more targets", true)
                else
                    TolkSpeak(info.SummarizeUnitInfo(id), false)
                end
            end
    end
end
    base(victim, triggerArgs)
end)

function M.CycleBeacon(direction, resetExistingTarget, interruptSpeech)
    local id, index, targetList = beaconTargets.GetNextBeaconTarget(direction)
if interruptSpeech == nil then interruptSpeech = true end
    if not id then
        PlaySound({ Name = "/Leftovers/SFX/OutOfAmmo" })
        TolkSpeak("No targets", interruptSpeech)
        beaconState:ResetTarget()
        return
    end

    if not beaconTargets.SetBeaconTarget(id, index, resetExistingTarget) then return end
        TolkSpeak(info.SummarizeUnitInfo(id), interruptSpeech)
end

function M.StopTracking()
    if beaconState.targetId then
    beaconState:ResetTarget(false)
            TolkSpeak("Tracking stopped", true)
    else
        TolkSpeak("Currently tracking nothing", true)
    end
end
function M.TogglePermaBeaconPin(args)
    local id = beaconState.targetId
    if not id or not IdExists({ Id = id}) then return end
    if beaconTargets.IsBeaconObjectPinned(id) then
        if not beaconTargets.UnpinPermaBeaconObject(id) then
            TolkSpeak("Invalid target")
        else
        TolkSpeak("Permanent beacon off")
        end
    else
        if not beaconTargets.PinPermaBeaconObject(id) then
            TolkSpeak("Invalid target")
        else
        TolkSpeak("Permanent beacon on")
        end
end
end
------------------------------------------------------------
-- Teleporting to beacon
------------------------------------------------------------
function M.TeleportToBeacon()
    if IsInputAllowed({}) and IsEmpty(ActiveScreens) then
        local target = beaconState.targetId
        local hero = CurrentRun.Hero
        if not target or not IdExists({ Id = target }) then
            TolkSpeak("No target selected", true)
            return
        end

        if IsCombatEncounterActive(CurrentRun) or not IsEmpty(RequiredKillEnemies) or not IsEmpty(MapState.AggroedUnits) then
            TolkSpeak("Cannot teleport while in active combat", true)
            return
        end

        if hero.JoinedInArtemisSong or hero.JoinedInWitchcraft then
            TolkSpeak("You are busy", true)
            return
        end
        local offsetX = 0
        local offsetY = -120



        TolkSpeak("Teleporting to "..GetDisplayName({ Text = info.GetObjectName(target), IgnoreIcons = true}), true)
        Teleport({ Id = CurrentRun.Hero.ObjectId, DestinationId = target, OffsetX = offsetX, OffsetY = offsetY })
    end
end
return M