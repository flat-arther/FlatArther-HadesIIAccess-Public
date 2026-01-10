-- Handles data that is initialized on game start. Mostly deals with groups

DeferredGroupInits = {}

function game.AddObjToGroup( source, args )
        if source == nil or source.ObjectId == nil then return end
    
    local id = source.ObjectId
    local groupName = args.AddToGroup
    local name = GetName({ Id = id })
    local inactives = GetInactiveIdsByType({ Name = name })
    
    if Contains(inactives, id) then
        DeferredGroupInits[id] = DeferredGroupInits[id] or {}
        if not Contains(DeferredGroupInits[id], groupName) then
            table.insert(DeferredGroupInits[id], groupName)
        end
    else
        AddToGroup({ Id = id, Name = groupName})
    end
end


local function SetGroups()
    local MainHub = {}
    local TrainingGrounds = {}
    local FlashbackHub = {}
    local FlashbackHubDeath = {}
    local RoomSetObstacleData = {}
    local Traps = {}
    local Weapons
    if MapState then
        Weapons = MapState.WeaponKits
    end
    if RoomData then
        for _, V in pairs(RoomData) do
                if V.ObstacleData then
                    OverwriteTableKeys(RoomSetObstacleData, V.ObstacleData)
                end
        end
    end
    if HubRoomData then
        MainHub = HubRoomData["Hub_Main"]
        TrainingGrounds = HubRoomData["Hub_PreRun"]
        FlashbackHub = HubRoomData["Flashback_Hub_Main"]
        FlashbackHubDeath = HubRoomData["Flashback_DeathArea"]
    end
    if UnitSetData then
        Traps = UnitSetData.Traps
    end

    local targets = {
        { Data = MainHub["ObstacleData"],           ObjectData = 560662,             Groups = { "Interactibles" },            HasSetUpEvent = true },
        { Data = FamiliarData, Groups = { "Familiars", "NPCs" }, HasSetUpEvent = true },
        { Data = MainHub["ObstacleData"],           ObjectData = 391697,             Groups = { "ExitDoors", "Interactibles" }, HasSetUpEvent = true },
        { Data = TrainingGrounds["ObstacleData"],   ObjectData = 421119,             Groups = { "ExitDoors", "Interactibles" }, HasSetUpEvent = true },
        { Data = TrainingGrounds["ObstacleData"],   ObjectData = 420947,             Groups = { "ExitDoors", "Interactibles" }, HasSetUpEvent = true },
        { Data = TrainingGrounds["ObstacleData"],   ObjectData = 558268,             Groups = { "ExitDoors", "Interactibles" }, HasSetUpEvent = true },
        { Data = TrainingGrounds["ObstacleData"],   ObjectData = 555784,             Groups = { "ExitDoors", "Interactibles" }, HasSetUpEvent = true },
        { Data = FlashbackHub["ObstacleData"],      ObjectData = 488298,             Groups = { "Interactibles" },            HasSetUpEvent = true,                                     FilterKeys = { "OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance" } },
        { Data = MainHub["ObstacleData"],           Groups = { "Interactibles" },    HasSetUpEvent = true,                    FilterKeys = { "OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance", } },
        { Data = FlashbackHub["ObstacleData"],      Groups = { "Interactibles" },    HasSetUpEvent = true,                    FilterKeys = { "OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance" } },
        { Data = FlashbackHubDeath["ObstacleData"], Groups = { "Interactibles" },    HasSetUpEvent = true,                    FilterKeys = { "OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance" } },
        { Data = TrainingGrounds["ObstacleData"],   Groups = { "Interactibles" },    HasSetUpEvent = true,                    FilterKeys = { "OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance" } },
        { Data = ObstacleData, Groups = { "Terrain"}, FilterKeys = {"MaxHealth"}, HasSetUpEvent = true},
        { Data = ObstacleData, Groups = { "Interactibles", }, HasSetUpEvent = true, FilterKeys = { "OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance", "RerollFunctionName", } },
        { Data = Traps,                             ObjectData = "BaseTrap",         Groups = { "Traps" },                    HasSetUpEvent = true },
        { Data = Traps,                             ObjectData = "DestructibleTree", Groups = { "Traps" },                    HasSetUpEvent = true },
        { Data = RoomSetObstacleData,               Groups = { "Interactibles" }, HasSetUpEvent = true, FilterKeys = {"OnUsedFunctionName", "SpecialInteractFunctionName", "InteractDistance", "RerollFunctionName", "DistanceTriggers" }},
    }

local function ProcessObject(objectData, targetEntry, sourceData)
        if type(objectData) ~= "table" then return end

        local groups = targetEntry.Groups
        local isEvent = targetEntry.HasSetUpEvent
        local filterKeys = targetEntry.FilterKeys

        if filterKeys then
            local passesFilter = false
            for _, key in ipairs(filterKeys) do
                local filterCurrent = objectData
                while filterCurrent do
                    if rawget(filterCurrent, key) then
                        passesFilter = true
                        break
                    end
                    local parentName = filterCurrent.InheritFrom and filterCurrent.InheritFrom[1]
                    filterCurrent = (parentName and sourceData) and sourceData[parentName] or nil
                end
                if passesFilter then break end
            end
            if not passesFilter then return end
        end

        local dataOwner = objectData
        local current = objectData
        while current do
            local hasData = false
            if isEvent then
                if rawget(current, "SetupEvents") then hasData = true end
            else
                if rawget(current, "Groups") then hasData = true end
            end

            if hasData then
                dataOwner = current
                break
            end

            local parentName = current.InheritFrom and current.InheritFrom[1]
            current = (parentName and sourceData) and sourceData[parentName] or nil
        end

        for _, groupName in ipairs(groups) do
            if isEvent then
                if not dataOwner.SetupEvents then dataOwner.SetupEvents = {} end
                local hasEvent = false
                for _, event in ipairs(dataOwner.SetupEvents) do
                    if event.FunctionName == "AddObjToGroup" and event.Args and event.Args.AddToGroup == groupName then
                        hasEvent = true; break
                    end
                end
                if not hasEvent then
                    table.insert(dataOwner.SetupEvents,
                        { FunctionName = "AddObjToGroup", Args = { AddToGroup = groupName } })
                end
            else
                if not dataOwner.Groups then dataOwner.Groups = {} end
                local alreadyExists = false
                for _, g in ipairs(dataOwner.Groups) do
                    if g == groupName then
                        alreadyExists = true; break
                    end
                end
                if not alreadyExists then table.insert(dataOwner.Groups, groupName) end
            end
        end
    end

    for _, v in ipairs(targets) do
        local gameData = v.Data
        local specificKey = v.ObjectData

        if gameData and v.Groups and #v.Groups > 0 then
            if specificKey and gameData[specificKey] then
                ProcessObject(gameData[specificKey], v, gameData)
            elseif not specificKey then
                for _, objectData in pairs(gameData) do
                    if not objectData.Template then 
                    ProcessObject(objectData, v, gameData)
                    end
                end
            end
        end
    end
end


-- Collision reaction data
local CollisionReactions = {
}
-- Useless for now but keeping it here just in case
local function InitCollisionReactions(data, newReactions)
    if not data or not newReactions then return end
    data.CollisionReactions = data.CollisionReactions or {}

    for _, newReaction in ipairs(newReactions) do
        local alreadyExists = false
        for _, existingReaction in pairs(data.CollisionReactions) do
            if existingReaction == newReaction then
                alreadyExists = true
                break
            end
        end

        if not alreadyExists then
            table.insert(data.CollisionReactions, newReaction)
        end
    end
end


function CheckDeferredInits( id )
    local groupList = DeferredGroupInits[id]
    local name = GetName({ Id = id })

    if groupList ~= nil then
        for _, groupName in ipairs(groupList) do
            AddToGroup({ Id = id, Name = groupName })
        end
        DeferredGroupInits[id] = nil
    end
end

rom.on_import.post(SetGroups)

