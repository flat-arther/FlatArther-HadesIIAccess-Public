-- Responsible for turning animation keys into friendly strings.
-- Relies on an AnimationFriendlyNames table (from data/animations.lua).

import 'data/animations.lua' 

local M = {}

function M.GetAnimation(args)
    if not args or (not args.Id and not args.Anim) then
        return nil
    end

    local Anim = args.Anim or GetThingDataValue({ Id = args.Id, Property = "Graphic" })
    if not Anim then return nil end

    local TranslatedOnly = args.TranslatedOnly or false

    if AnimationFriendlyNames then
        local TranslatedAnim = AnimationFriendlyNames[Anim]
        if TranslatedAnim then
            return TranslatedAnim
        end
    end

    if TranslatedOnly then
        return nil
    end

    local CleanName = Anim
    CleanName = CleanName
        :gsub("^Enemy_", "")
        :gsub("^Melinoe_", "")
        :gsub("^Unit_", "")
        :gsub("^NPC_", "")
        :gsub("_Start$", "")
        :gsub("_Loop$", "")
        :gsub("_End$", "")
        :gsub("_Fire$", "")
        :gsub("_", " ")
        :gsub("(%l)(%u)", "%1 %2")

    return CleanName
end

return M
