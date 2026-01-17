local _, Private = ...

-- Color percentile
function Private.GetColorForPercentile(p)
    if p >= 100 then return "|cffffd100"
    elseif p >= 99 then return "|cffff66ff"
    elseif p >= 95 then return "|cffff8000"
    elseif p >= 90 then return "|cffff2020"
    elseif p >= 75 then return "|cffa335ee"
    elseif p >= 50 then return "|cff0070dd"
    elseif p >= 25 then return "|cff1eff00"
    else return "|cff9d9d9d" end
end

-- Clear numbers
function Private.FormatNumber(n)
    local str = tostring(n)
    local k
    while true do
        str, k = string.gsub(str, "^(-?%d+)(%d%d%d)", "%1 %2")
        if k == 0 then break end
    end
    return str
end

-- Format DPS with k (26854 -> 26.8k)
function Private.FormatDPS(dps)
    if not dps then return "0" end

    if dps >= 1000 then
        local value = math.floor(dps / 100) / 10
        return value .. "k"
    else
        return tostring(dps)
    end
end

-- Return Icon Spec
function Private.GetSpecIcon(classFile, specID)
    local icons = Private.SPEC_ICONS[classFile]
    return icons and icons[specID] or nil
end

-- Find the target spec without group/raid
function Private.GuessSpecByMostKills(name, classID)
    local bestSpecID, maxKills = nil, -1

    for specID = 1, 3 do
        local entry = UWULogsData[classID] and UWULogsData[classID][specID]
        local data = Private.ParsePlayerData(entry, name)
        if data and data.b then
            local totalKills = 0
            for _ in pairs(data.b) do
                totalKills = totalKills + 1
            end
            if totalKills > maxKills then
                maxKills = totalKills
                bestSpecID = specID
            end
        end
    end

    return bestSpecID
end

-- Parse player from UWULogsData
function Private.ParsePlayerData(entry, playerName)
    if type(entry) ~= "table" then return nil end

    for _, line in ipairs(entry) do
        local name, po, rank, bossStr = string.match(line, "([^|]+)|([^|]+)|([^|]+)|(.+)")
        if name == playerName then
            local data = {
                po = tonumber(po),
                r = tonumber(rank),
                b = {}
            }
            for bossSegment in string.gmatch(bossStr or "", "[^,]+") do
                local key, dps, p, r = string.match(bossSegment, "([^:]+):([^:]+):([^:]+):([^:]+)")
                if key and dps and p then
                    data.b[key] = { dps = tonumber(dps), p = tonumber(p), r = tonumber(r) }
                end
            end
            return data
        end
    end

    return nil
end