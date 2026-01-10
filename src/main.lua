---@meta _

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

mods['SGG_Modding-ENVY'].auto()
rom = rom
_PLUGIN = _PLUGIN

---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

-- mod dependencies
modutil = mods['SGG_Modding-ModUtil']
chalk   = mods['SGG_Modding-Chalk']
reload  = mods['SGG_Modding-ReLoad']

------------------------------------------------------------
-- Config
------------------------------------------------------------

config = chalk.auto 'config.lua'

------------------------------------------------------------
-- Static / data
------------------------------------------------------------

import 'data/initData.lua'
import 'data/icons.lua'
import 'data/StaticIdDisplayNames.lua'

-- Global state stuff
DOUBLE_TAP_THRESHOLD = config.AccessModControls.DOUBLE_TAP_THRESHOLD or 0.25
beaconState    = import 'beacon/state.lua'
local beaconAudio
local beaconMath
local beaconCommands
local beaconTargets
local function on_ready()
    -- Beacon system 
beaconCommands = import 'beacon/commands.lua'
beaconAudio    = import 'beacon/audio.lua'
beaconMath     = import 'beacon/math.lua'
beaconTargets = import 'beacon/targets.lua'
info = import 'objinfo/general.lua'


    -- Input hooks / animation wraps
import 'ready.lua'
end


------------------------------------------------------------
-- Beacon audio loop
------------------------------------------------------------

local THREAD_NAME = "BeaconLoop"

OnAnyLoad { function()
    -- Reinnitialize collision reactions
    if CurrentRun and CurrentRun.Hero then
    local currentReactions = CurrentRun.Hero.CollisionReactions or {}
    local dataReactions = HeroData.CollisionReactions or {}

    for k in pairs(currentReactions) do
        currentReactions[k] = nil
    end

    for i, reaction in ipairs(dataReactions) do
        currentReactions[i] = reaction
    end
    
    CurrentRun.Hero.CollisionReactions = currentReactions
end

    local bankPath = rom.path.combine( _PLUGIN.plugins_data_mod_folder_path, "Audio\\tracking_beacon.bank"
    )
    if rom.audio and rom.audio.load_bank then
        rom.audio.load_bank(bankPath)
    end

    if HasThread(THREAD_NAME) then
        return
    end

    thread(function()
        while true do
            -- clean stale double-tap entries
            beaconState:DoubletapCleanup()

-- Disable beacon layer in case control release is not registered or a screen is open
beaconState:TrackingCleanup()

            local enabled = config and config.TrackingBeaconGlobal and config.TrackingBeaconGlobal.Toggle

            local hero = CurrentRun and CurrentRun.Hero
            local targetId = beaconState.targetId

            if enabled and hero and targetId and IdExists({ Id = targetId }) and IsInputAllowed({}) and IsEmpty(ActiveScreens) then
                local dist = GetDistance({ Id = hero.ObjectId, DestinationId = targetId }) or 0

                local interval = beaconMath.ComputeBeaconInterval(dist)
                local facing   = beaconMath.GetFacingDotProduct({ TargetId = targetId, IsAlwaysNorth = true})

                local sound
                if facing > 0.3 then
                    sound = beaconAudio.front
                elseif facing < -0.3 then
                    sound = beaconAudio.back
                else
                    sound = beaconAudio.normal
                end
if CheckCooldown("TrackingBeaconSound", interval, true) then
                beaconAudio.PlayBeaconSound(sound, targetId)
end
        end
            wait(0.02, THREAD_NAME)
        end
    end)
end }

------------------------------------------------------------
-- Reload handling
------------------------------------------------------------


local function on_reload()
import 'reload.lua'

end

local loader = reload.auto_single()
modutil.once_loaded.game(function()
    loader.load(on_ready, on_reload)
end)

local reloadPoll

reload.trigger( "HadesIIAccessReload", function(poll)
        reloadPoll = poll
    end, 
    true)
