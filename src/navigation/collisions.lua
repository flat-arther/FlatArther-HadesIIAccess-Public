-- Handles collision sound feedback

local lastSpokenCollidee = 0
local AccessModWallHitSound = config.AccessModNavigation.WallCollisionSound or "{0381e8ca-ae3a-41ea-99b2-cc64dc0fff55}"

OnObstacleCollision {
    function(triggerArgs)
        local collider = triggerArgs.TriggeredByTable
        if collider.ObjectId ~= CurrentRun.Hero.ObjectId then return end
        local collidee = triggerArgs.CollideeTable
        local now = _worldTime
-- Finicky way to do it but it works. Save time when player moves, then check against it later to prevent move starts from playing the sound
        if IsMoving({ Id = collider.ObjectId }) then
            SessionState.LastHeroMoveTime = now
            return
        end

        local timeSinceMove = now - (SessionState.LastHeroMoveTime or 0)

        if timeSinceMove > 0.1 then
            return
        end

        if not CheckCooldown("WallCollisionSound", 0.4) then return end

        local currentId = -1
        local nameToSpeak = "Impassable obstacle"
local objName = ""
        if collidee then
            currentId = collidee.ObjectId
            objName = GetName({ Id = collidee.ObjectId })
            nameToSpeak = GetDisplayName({ Text = objName })
        end

        if not collidee then
            PlaySound({ Name = AccessModWallHitSound, Id = collider.ObjectId })
            thread(DoRumble, { { ScreenPreWait = 0, Fraction = 0.15, Duration = 0.1 } })
        end

        if lastSpokenCollidee ~= currentId then
            lastSpokenCollidee = currentId
            if config.AccessDisplay.AnnounceObstacles then
            TolkSpeak(nameToSpeak)
            end
        end
    end
}