local M = {}

M.categoryIndex = 0
M.targetIndex = 1
M.targetId = nil
M.lastTargetId = nil
M.lastControlRelease = {}
M.controlHolds = {}
M.consumedControls = {}
M.isModLayer = false
M.isConfigLayer = false
M.PermaBeaconTargets = {}

function M:ResetTarget(resetIndex)
    self.targetId = nil

    if resetIndex ~= false then
        self.targetIndex = 1
        self.lastTargetId = nil
    end
end

-- Cleanup functions
function M:DoubletapCleanup()
    local now = _worldTimeUnmodified
    if now then
        for control, t in pairs(self.lastControlRelease) do
            if now - t > DOUBLE_TAP_THRESHOLD then
                self.lastControlRelease[control] = nil
            end
        end
    end
end

function M:TrackingCleanup()
    if not IsControlDown({ Name = ModControl }) then
        self.isModLayer = false
        UnfreezePlayerUnit("TrackingBeacon")
        RemoveControlBlock("Use", "TrackingBeacon")
        RemoveControlBlock("SpecialInteract", "TrackingBeacon")
        SessionMapState.BlockInventory = false
    end
end

function M:HandleControlHolds()
for control, args in pairs(self.controlHolds) do
    if not IsControlDown({ Name = control }) then
        self:RemoveControlHold(control)
    else
    if args ~= nil then
        if CheckCooldownNoTrigger("AccessMod_"..control.."_Hold", args.Timer, true) and args.Handler then
            args.Handler({Control = control, Timer = args.Timer})
            self:RemoveControlHold(control, true)
        end
end
end
end
end

function M:AddControlHold(name, time, handler)
    if not name or not time then return end
    SessionState.GlobalCooldowns["AccessMod_"..name.."_Hold"] = _worldTimeUnmodified
    self.controlHolds[name] = { Timer = time, Handler = handler}
end

function M:RemoveControlHold(name, consumeControl)
    if not name then return end
    if consumeControl then
        self.consumedControls[name] = true
    end
    ResetCooldown("AccessMod_"..name.."_Hold")
    self.controlHolds[name] = nil
end
return M
