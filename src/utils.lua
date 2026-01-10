import 'data/icons.lua'
import 'data/StaticIdDisplayNames.lua'

function NormalizeToTable(x)
    if type(x) == "table" then
        return x
    end
    return { x }
end


function SortByClosest(ids)
    if not ids then return {} end
    local heroId = CurrentRun and CurrentRun.Hero and CurrentRun.Hero.ObjectId
    if not heroId then return ids end

    local temp = {}
    for _, v in ipairs(ids) do
        table.insert(temp, {
            Id = v,
            Distance = GetDistance({ Id = heroId, DestinationId = v })
        })
    end
    table.sort(temp, function(a, b) return a.Distance < b.Distance end)
    return temp
end

function SortByScore(ids)
    if not ids or #ids == 0 or not CurrentRun or not CurrentRun.Hero then
        return {}
    end

    local heroId = CurrentRun.Hero.ObjectId
    local scoredList = {}

    for _, id in ipairs(ids) do
        if IdExists({ Id = id }) then
            local classification = beaconTargets.ClassifyTarget(id)
            local baseScore = 0
            local obj = nil

            if classification == "Unit" then
                obj = ActiveEnemies[id]
                if obj then baseScore = beaconMath.ScoreUnit(obj) end
            elseif classification == "Loot" then
                obj = LootObjects[id] or (MapState.ActiveObstacles and MapState.ActiveObstacles[id])
                if obj then baseScore = beaconMath.ScoreLoot(obj) end
            elseif classification == "Door" then
                obj = (MapState.OfferedExitDoors and MapState.OfferedExitDoors[id]) or (MapState.ShipWheels and MapState.ShipWheels[id])
                if obj then baseScore = beaconMath.ScoreDoor(obj) end
            elseif classification == "Obstacle" then
                obj = MapState.ActiveObstacles[id]
                if obj then baseScore = beaconMath.ScoreObstacle(obj) end
            elseif classification == "Weapon" then
                obj = MapState.WeaponKits[id]
                if obj then baseScore = beaconMath.ScoreWeapon(obj) end
            end

            if IsUseable({ Id = id }) then
                baseScore = baseScore + 0.5
            end

            local categoryWeight = 1
            categoryWeight = config.TrackingBeaconGlobal.CategoryWeights[classification] or 0

            local weightedScore = baseScore * categoryWeight

            local dist = GetDistance({
                Id = heroId,
                DestinationId = id
            }) or math.huge

            local distanceTieBreak = 1 / (1 + dist)

            table.insert(scoredList, {
                Id = id,
                Score = weightedScore,
                Distance = dist,
                TieBreak = distanceTieBreak
            })
        end
    end

    table.sort(scoredList, function(a, b)
        if a.Score ~= b.Score then
            return a.Score > b.Score
        end
        return a.TieBreak > b.TieBreak
    end)

    return scoredList
end

local function GetIconFriendlyText(raw)
    raw = raw:gsub("Icons%.", "")
    if FriendlyIcons[raw] then
        return FriendlyIcons[raw]
    end
    return raw:gsub("(.)(%u)", function(char1, char2)
        return char1 .. " " .. char2:lower()
    end)
end

local function formatIconsString(raw)
    local BYTE_LEFT_BRACE = string.byte("{")
    local BYTE_BANG = string.byte("!")

    local outputBuffer = {}
    local outWriteCursor = 1
    local readCursor = 1
    local rawLen = #raw

    while readCursor <= rawLen do
        local currentByte = raw:byte(readCursor)

        if currentByte == BYTE_LEFT_BRACE then
            if readCursor < rawLen and raw:byte(readCursor + 1) == BYTE_BANG then
                local endBrace = raw:find("}", readCursor + 2)

                if endBrace then
                    local iconTagString = raw:sub(readCursor + 2, endBrace - 1)

                    local iconFriendlyText = GetIconFriendlyText(iconTagString)

                    outputBuffer[outWriteCursor] = iconFriendlyText
                    outWriteCursor = outWriteCursor + 1

                    readCursor = endBrace + 1
                else
                    outputBuffer[outWriteCursor] = "{!"
                    outWriteCursor = outWriteCursor + 1
                    readCursor = readCursor + 2
                end
            else
                outputBuffer[outWriteCursor] = "{"
                outWriteCursor = outWriteCursor + 1
                readCursor = readCursor + 1
            end
        else
            local nextBrace = raw:find("{", readCursor)
            local tagEnd = nextBrace and (nextBrace - 1) or rawLen

            outputBuffer[outWriteCursor] = raw:sub(readCursor, tagEnd)
            outWriteCursor = outWriteCursor + 1

            readCursor = tagEnd + 1
        end
    end

    return table.concat(outputBuffer)
end

modutil.mod.Path.Wrap("GetDisplayName", function(base, args)
    local display = base(args)
    if not args.IgnoreIcons then
        display = formatIconsString(display)
    else
        display = display:gsub("{!Icons%..-}%s", "")
    end
    display = display:gsub("Drop", ""):gsub("RoomReward", ""):gsub("StoreReward", ""):gsub("([^%u])(%u)", "%1 %2"):gsub("0%d+$", ""):gsub(" ë", "ë")-- Hacky but works
    return display
end)

modutil.mod.Path.Wrap("GetName", function(base, args)
    if StaticIdDisplayNames and StaticIdDisplayNames[args.Id] then
        return StaticIdDisplayNames[args.Id]
    end
    return base(args)
end)

function TolkSpeak(Text, interrupt)
    if not Text then return end
    Text = tostring(Text)
    interrupt = interrupt or false
    if interrupt and rom and rom.tolk then rom.tolk.silence() end
    if rom and rom.tolk then rom.tolk.output(Text) end
end
