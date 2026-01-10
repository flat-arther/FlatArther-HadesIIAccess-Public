---@meta HadesIIAccess-Mod
local public = {}

--------------------------------------------------------------------------------
-- Beacon user-facing controls
--------------------------------------------------------------------------------

--- Cycle the current beacon target.
--- direction: 0 = nearest, 1 = next, -1 = previous
---@param direction number
---@return number? targetId
function public.CycleBeacon(direction) end

--- Cycle beacon filter category.
---@param direction number
---@return string categoryName
function public.CycleBeaconCategory(direction) end

--- Toggle beacon sound on/off.
---@return boolean enabled
function public.ToggleBeaconSound() end

--- Speak information about a target via Tolk.
---@param id number
---@return boolean success
function public.SpeakTargetInfo(id) end

return public
