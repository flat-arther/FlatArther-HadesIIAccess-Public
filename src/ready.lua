---@meta _
---@diagnostic disable: lowercase-global

-- Mostly contains control hooks and wrapped functions

local animation  = import 'objinfo/animationHelpers.lua'
-- Navigation
import 'navigation/collisions.lua'
-- Controls
local isControlConsumed          = false
-- ModControl is global so that other scripts can access it
ModControl                       = "AttackTurbo"
local BeaconPrevCatControl       = "Confirm"
local BeaconNextCatControl       = "MenuInfo"
local BeaconPrevTargetControl    = "MenuLeft"
local BeaconNextTargetControl    = "MenuRight"
local BeaconTargetClosestControl = "Select"
local BeaconInfoControl          = "Cancel"

local FreezePlayerArgs           = {
    AllowedKeys = {
        ModControl,
        BeaconPrevCatControl,
        BeaconNextCatControl,
        BeaconPrevTargetControl,
        BeaconNextTargetControl,
        "ExorcismLeft",
        "ExorcismRight",
    }
}

--------------------------------------------------------------------------------
-- Prevent Codex opening when our modifier is down
--------------------------------------------------------------------------------
modutil.mod.Path.Wrap("CanOpenCodex", function(base, args)
    if beaconState.isModLayer then
        return false
    end
    return base(args)
end)

modutil.mod.Path.Wrap("CannotOpenCodexPresentation", function(base, args)
    if beaconState.isModLayer then
        return
    end
    return base(args)
end)

--------------------------------------------------------------------------------
-- Modifier press/release: freeze player and block conflicting controls
--------------------------------------------------------------------------------
OnControlPressed { ModControl, function(triggerArgs)
        beaconState.isModLayer = true
        AddControlBlock("Use", "TrackingBeacon")
        AddControlBlock("SpecialInteract", "TrackingBeacon")
        SessionMapState.BlockInventory = true
        if IsInputAllowed({ }) then
        FreezePlayerUnit("TrackingBeacon", FreezePlayerArgs)
        end
end }

OnControlReleased { ModControl, function(triggerArgs)
    beaconState:TrackingCleanup()
        local now = _worldTimeUnmodified
        local prev = beaconState.lastControlRelease[ModControl]
        if prev and (now - prev) <= DOUBLE_TAP_THRESHOLD then
            -- double-tap detected: reset tracking state
            beaconState:ResetTarget(false)
            TolkSpeak("Tracking stopped", true)
            beaconState.lastControlRelease[ModControl] = nil
            return
        end
        beaconState.lastControlRelease[ModControl] = now
end }

--------------------------------------------------------------------------------
-- Target / Category cycling bindings
--------------------------------------------------------------------------------
OnControlPressed { BeaconPrevTargetControl, function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.CycleBeacon(-1)
    end
end }


OnControlPressed { BeaconTargetClosestControl, function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.CycleBeacon(0)
    end
end }

OnControlPressed { BeaconNextTargetControl, function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.CycleBeacon(1)
    end
end }

OnControlPressed { BeaconPrevCatControl, function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.CycleBeaconCategory(-1)
    end
end }

OnControlPressed { BeaconNextCatControl, function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.CycleBeaconCategory(1)
    end
end }

OnControlPressed { BeaconInfoControl, function(triggerArgs)
    if beaconState.isModLayer then
        info.SpeakTargetInfo(beaconState.targetId)
    end
end }

OnControlPressed { BeaconToggleControl, function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.ToggleBeaconSound()
    end
end }

OnControlPressed { "Codex", function(triggerArgs)
    if beaconState.isModLayer then
        info.SpeakTargetInfo(CurrentRun.Hero.ObjectId)
    end
end }

OnControlPressed { "Inventory", function(triggerArgs)
    if beaconState.isModLayer then
        beaconCommands.TeleportToBeacon()
    end
end }


--------------------------------------------------------------------------------
-- Keyboard controls
--------------------------------------------------------------------------------
rom.inputs.on_key_pressed{"Shift OemOpenBrackets", Name = "Beacon: Previous Category", function()
    SetPlayerInvulnerable("Balls")
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
        beaconCommands.CycleBeaconCategory(-1)
    end
end}

rom.inputs.on_key_pressed{"Shift OemCloseBrackets", Name = "Beacon: Next Category", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
        beaconCommands.CycleBeaconCategory(1)
    end
end}

rom.inputs.on_key_pressed{"None OemOpenBrackets", Name = "Beacon: Previous Target", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
        beaconCommands.CycleBeacon(-1)
    end
end}

rom.inputs.on_key_pressed{"None OemCloseBrackets", Name = "Beacon: Next Target", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
        beaconCommands.CycleBeacon(1)
    end
end}

rom.inputs.on_key_pressed{"None OemPipe", Name = "Beacon: Track Closest", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
        beaconCommands.CycleBeacon(0)
    end
end}

rom.inputs.on_key_pressed{"None OemQuotes", Name = "Beacon: Target Info", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
            info.SpeakTargetInfo(beaconState.targetId)
    end
end}

rom.inputs.on_key_pressed{"None P", Name = "Beacon: Hero Info", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
            info.SpeakTargetInfo(CurrentRun.Hero.ObjectId)
    end
end}

rom.inputs.on_key_pressed{"None O", Name = "Beacon: Hero Info", function()
    if CurrentRun and CurrentRun.Hero and SessionMapState and not SessionMapState.IsPaused  and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
            beaconCommands.TeleportToBeacon()
    end
end}

--------------------------------------------------------------------------------
-- animation announce handling
--------------------------------------------------------------------------------
local ConversationActive = false
local ConversationParticipants = {}
local lastAnnouncedAnim = nil
local lastAnnouncedTarget = nil
local lastAnnouncedName = nil

local function AddParticipant(entity)
    if not entity then return end

    if type(entity) == "table" and entity.ObjectId then
        ConversationParticipants[entity.ObjectId] = true
    elseif type(entity) == "number" then
        ConversationParticipants[entity] = true
    elseif type(entity) == "string" then
        local ids = GetIdsByType({ Name = entity })
        if ids then
            for _, id in pairs(ids) do
                ConversationParticipants[id] = true
            end
        end
    end
end

-- Wrap PlayTextLines to track conversation participants
modutil.mod.Path.Wrap("PlayTextLines", function(base, source, textLines, args)
    ConversationActive = true
    ConversationParticipants = {}

    if CurrentRun and CurrentRun.Hero then
        AddParticipant(CurrentRun.Hero)
    end

    AddParticipant(source)

    if textLines then
        if textLines.Partner then
            AddParticipant(textLines.Partner)
        end

        if source and source.NextInteractLines and source.NextInteractLines.Partner then
            AddParticipant(source.NextInteractLines.Partner)
        end
    end

    local result = base(source, textLines, args)

    ConversationActive = false
    ConversationParticipants = {}

    return result
end)


modutil.mod.Path.Wrap("SetAnimation", function(base, args)
    local result = base(args)


    local announceEnabled = (config and ((config.TrackingBeaconGlobal and config.TrackingBeaconGlobal.AnnounceAnimations) or (config.AccessDisplay and config.AccessDisplay.AnnounceAnimations)))
    if not announceEnabled then
        return result
    end

    if not args or not args.DestinationId or not args.Name then
        return result
    end

    local shouldAnnounce = false

    if ConversationActive then
        local announceDuringDialog = config.AccessDisplay.AnnounceAnimationsDuringDialog
        if not announceDuringDialog then return result end
        if ConversationParticipants[args.DestinationId] then
            shouldAnnounce = true
        end
    else
        if beaconState.targetId and args.DestinationId == beaconState.targetId then
            shouldAnnounce = true
        end
    end

    if shouldAnnounce then
        if lastAnnouncedTarget ~= args.DestinationId then
            lastAnnouncedAnim = nil
            lastAnnouncedTarget = args.DestinationId
            lastAnnouncedName = nil
        end

        if args.Name ~= lastAnnouncedAnim then
            lastAnnouncedAnim = args.Name
            local spoken = animation.GetAnimation({ Anim = args.Name })
            if not lastAnnouncedName then
                lastAnnouncedName = GetDisplayName({Text = info.GetObjectName(args.DestinationId), IgnoreIcons = true})
                spoken = lastAnnouncedName.." "..spoken
            end
            if spoken and spoken ~= "" then
                TolkSpeak(spoken, true)
            end
        end
    end

    return result
end)

-- Wrap activate to check for deferred group inits
ModUtil.Path.Wrap("Activate", function(baseFunc, args)
    baseFunc(args)

    if args.Id or args.Ids then
        for _, id in ipairs(NormalizeToTable(args.Ids or args.Id)) do
            CheckDeferredInits(id)
        end
    end

    if args.Names then
        for _, name in ipairs(args.Names) do
            local ids = GetIdsByType({ Name = name })
            for _, id in ipairs(ids) do
                CheckDeferredInits(id)
            end
        end
    end
end)
