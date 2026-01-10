local M = {}

M.categoryIndex = 0
M.targetIndex = 1
M.targetId = nil
M.lastTargetId = nil
M.lastBeaconSoundId = nil
M.lastControlRelease = {}
M.isModLayer = false

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
    if not IsControlDown({ Name = ModControl}) then
    self.isModLayer = false
    UnfreezePlayerUnit("TrackingBeacon")
    RemoveControlBlock("Use", "TrackingBeacon")
    RemoveControlBlock("SpecialInteract", "TrackingBeacon")    
    SessionMapState.BlockInventory = false
end
end


return M
