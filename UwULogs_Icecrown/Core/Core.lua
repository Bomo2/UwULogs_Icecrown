local _, Private = ...
local LGT = LibStub("LibGroupTalents-1.0", true)

local delayedTooltipFrame = CreateFrame("Frame")

local function ShowUWULogsTooltip(tooltip, unit)
    if not UWULogsData then return end

    local name, realm = UnitName(unit)
    realm = realm or GetRealmName()
    if not name or not realm then return end

    local _, classFile = UnitClass(unit)
    local classID = Private.classFile_to_id[classFile]
    if not classID or not UWULogsData[classID] then return end

   local specID

    if LGT and UnitIsPlayer(unit) and (UnitInParty(unit) or UnitInRaid(unit)) then
        local talentName = LGT:GetUnitTalentSpec(unit)
        if talentName and Private.UWULogsSpecMapping[classFile] then
            specID = Private.UWULogsSpecMapping[classFile][talentName]
        end
    end

    if not specID and not (UnitInParty(unit) or UnitInRaid(unit)) then
        specID = Private.GuessSpecByMostKills(name, classID)
    end

    if not specID or specID == 0 then return end

    local entry = UWULogsData[classID][specID]
    local data = Private.ParsePlayerData(entry, name)
    if not data then return end

    tooltip:AddLine(" ")
    local icon = Private.GetSpecIcon(classFile, specID)
    local color = Private.GetColorForPercentile(data.po)
    local left = icon and string.format("|T%s:28:28:0:0|t %s%d%%|r", icon, color, data.po or 0)
    local right = string.format("|cffffffffRank: %d|r", data.r or 0)
    tooltip:AddDoubleLine(left, right)

    for _, bossKey in ipairs(Private.BossOrder) do
      local boss = data.b[bossKey]
      if boss then
        local bcolor = Private.GetColorForPercentile(boss.p)

        local left = string.format("|cff00bbff[R%d]|r  |cffffffff%s (%s DPS)|r", boss.r or 0, Private.BossNameLookup[bossKey], Private.FormatDPS(boss.dps))
        local right = string.format("%s%d%%|r", bcolor, boss.p)

        tooltip:AddDoubleLine(left, right)
    end
end

tooltip:Show()

end

local function OnDelayedTooltipUpdate(self)
    if not self.tooltip:IsShown() or not UnitExists(self.unit) then
        TooltipState = nil
        self:SetScript("OnUpdate", nil)
        self:Hide()
        return
    end

    if GetTime() - self.startTime >= self.delay then
        TooltipState = nil
        self:SetScript("OnUpdate", nil)
        self:Hide()
        ShowUWULogsTooltip(self.tooltip, self.unit)
    end
end

local function ShowUWULogsTooltipFromSearch(_, name, classID, specID)
    if not UWULogsData then return end
    local entry = UWULogsData[classID] and UWULogsData[classID][specID]
    local data = Private.ParsePlayerData(entry, name)
    if not data then return end
    Private.CreateOrShowInfoFrame(name, classID, specID, data)
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if InCombatLockdown() or TooltipState or UnitIsDeadOrGhost("player") then return end
    local _, unit = self:GetUnit()
    if not unit or not UnitExists(unit) then return end
    TooltipState = self
    delayedTooltipFrame.startTime = GetTime()
    delayedTooltipFrame.unit = unit
    delayedTooltipFrame.tooltip = self
    delayedTooltipFrame.delay = 1.3
    delayedTooltipFrame:SetScript("OnUpdate", OnDelayedTooltipUpdate)
    delayedTooltipFrame:Show()
end)

GameTooltip:HookScript("OnHide", function(self)
    if TooltipState == self then
        TooltipState = nil
        delayedTooltipFrame:SetScript("OnUpdate", nil)
        delayedTooltipFrame:Hide()
        delayedTooltipFrame.unit = nil
        delayedTooltipFrame.tooltip = nil
    end
end)

_G.ShowUWULogsTooltip = ShowUWULogsTooltip
_G.ShowUWULogsTooltipFromSearch = ShowUWULogsTooltipFromSearch