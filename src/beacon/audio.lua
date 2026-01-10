
local M = {}

M.normal = config.TrackingBeaconSounds and config.TrackingBeaconSounds.Normal
M.front  = config.TrackingBeaconSounds and config.TrackingBeaconSounds.Front
M.back   = config.TrackingBeaconSounds and config.TrackingBeaconSounds.Behind


function M.PlayBeaconSound(soundName, targetId)
    if not soundName then return nil end

    if beaconState.lastBeaconSoundId then
        StopSound({ Id = beaconState.lastBeaconSoundId })
        beaconState.lastBeaconSoundId = nil
    end

    local sid = PlaySound({ Name = soundName, Id = targetId })
    beaconState.lastBeaconSoundId = sid
    lastBeaconSoundId = sid
    return sid
end

function M.StopBeaconSound()
    if beaconState.lastBeaconSoundId then
        StopSound({ Id = beaconState.lastBeaconSoundId })
        beaconState.lastBeaconSoundId = nil
        lastBeaconSoundId = nil
    end
end

return M
