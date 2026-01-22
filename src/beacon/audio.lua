local M        = {}
-- Config

M.beaconNormal = config.TrackingBeaconSounds and config.TrackingBeaconSounds.BeaconNormal
M.beaconFront = config.TrackingBeaconSounds and config.TrackingBeaconSounds.BeaconFront
M.beaconBack = config.TrackingBeaconSounds and config.TrackingBeaconSounds.BeaconBehind
M.permaBeaconNormal = config.TrackingBeaconSounds.PermaBeaconNormal
M.permaBeaconFront = config.TrackingBeaconSounds.PermaBeaconFront
M.permaBeaconBack = config.TrackingBeaconSounds.PermaBeaconBehind

function M.PlayBeaconSound(soundName, targetId, instanceName)
    if not soundName then return nil end

    M.StopBeaconSound(instanceName)
    local sid = PlaySound({ Name = soundName, Id = targetId, ManagerCap = 100 })

    beaconState["last"..instanceName.."Id"] = sid
    return sid
end

function M.StopBeaconSound(name)
    if beaconState["last" .. name .. "Id"] then
        StopSound({ Id = beaconState["last" .. name .. "Id"] })
        beaconState["last" .. name .. "Id"] = nil
    end
end

function M.GetCurrentBeaconSound(id)
    if not CurrentRun or not CurrentRun.Hero then return end
    local sound
    local facing = beaconMath.GetFacingDotProduct({ TargetId = id, IsAlwaysNorth = true })
    if facing > 0.3 then
        sound = "Front"
    elseif facing < -0.3 then
        sound = "Back"
    else
        sound = "Normal"
    end
    return sound
end

function M.DoBeaconSound()
    if not CurrentRun or not CurrentRun.Hero then return end

    local hero = CurrentRun and CurrentRun.Hero
    local targetId = beaconState.targetId
    local enabled = config and config.TrackingBeaconGlobal and config.TrackingBeaconGlobal.Toggle
    if not (enabled and hero and targetId and IdExists({ Id = targetId }) and IsInputAllowed({}) and IsEmpty(ActiveScreens)) then return end
    local dist = GetDistance({ Id = hero.ObjectId, DestinationId = targetId }) or 0
    local interval = beaconMath.ComputeBeaconInterval(dist)
    if not CheckCooldown("TrackingBeaconSound", interval, true) then return end
    local sound = M["beacon" .. M.GetCurrentBeaconSound(targetId)]
    M.PlayBeaconSound(sound, targetId, "BeaconSound")
end

function M.DoPermaSoundMarkers()
    if not CurrentRun or not CurrentRun.Hero then return end
    local hero = CurrentRun and CurrentRun.Hero
    local targets = GetIdsByType({ Names = beaconState.PermaBeaconTargets})
    local enabled = config and config.TrackingBeaconGlobal and config.TrackingBeaconGlobal.Toggle
    if not (enabled and hero and #targets > 0 and IsInputAllowed({}) and IsEmpty(ActiveScreens)) then return end
    for i, target in ipairs(targets) do
        if IdExists({ Id = target }) and target ~= beaconState.targetId and beaconTargets.IsValidBeaconTarget(target) then
            local dist = GetDistance({ Id = hero.ObjectId, DestinationId = target }) or 0
            local interval = 0.5
            if config.TrackingBeaconGlobal.UseDistanceForPermanentBeaconInterval then
                interval = beaconMath.ComputeBeaconInterval(dist)
            else
            interval = beaconMath.IndexToInterval(i, 100)
            end
            if CheckCooldown("TrackingBeaconSound" .. target, interval, true) then
                local sound = M["permaBeacon" .. M.GetCurrentBeaconSound(target)]
                M.PlayBeaconSound(sound, target, "PermaMarker_"..target)
            end
        end
    end
end

return M
