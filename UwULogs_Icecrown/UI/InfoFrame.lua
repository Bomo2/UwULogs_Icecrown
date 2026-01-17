local _, Private = ...

local CLASS_COLORS = Private.CLASS_COLORS
local BossNameLookup = Private.BossNameLookup
local GetColorForPercentile = Private.GetColorForPercentile
local FormatNumber = Private.FormatNumber

local function CreateOrShowInfoFrame(name, classID, specID, data)
    if not UwULogsInfoFrame then
        local f = CreateFrame("Frame", "UwULogsInfoFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)

        f:SetSize(500, 320)
        f:SetPoint("CENTER")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)

        -- Top layer and interactable
        f:SetToplevel(true)
        f:SetFrameStrata("FULLSCREEN_DIALOG")
        f:SetFrameLevel(9999)

        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        f:SetBackdropColor(0, 0, 0, 1)

        -- Create a container for content
        local content = CreateFrame("Frame", nil, f)
        content:SetAllPoints(f)
        content:SetFrameLevel(f:GetFrameLevel() + 1)
        f.content = content

        -- Close button ABOVE content frame
        local closeButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        closeButton:SetSize(80, 22)
        closeButton:SetPoint("BOTTOM", 0, 12)
        closeButton:SetFrameLevel(f:GetFrameLevel() + 2)
        closeButton:SetText("Close")
        closeButton:SetScript("OnClick", function() f:Hide() end)

        UwULogsInfoFrame = f
    else
        UwULogsInfoFrame:Show()
        UwULogsInfoFrame:Raise()
    end

    local frame = UwULogsInfoFrame
    local content = frame.content

    local classFile
    for k, v in pairs(Private.classFile_to_id) do
        if v == classID then
            classFile = k
            break
        end
    end

    local classColor = CLASS_COLORS[classFile] or "|cffffffff"
    local po = data.po or 0
    local rank = data.r or 0
    local poColor = GetColorForPercentile(po)
    local poText = po == 100 and "100%" or string.format("%.2f%%", po)

    -- Titles
    content.titleLeft = content.titleLeft or content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.titleLeft:SetPoint("TOPLEFT", 18, -12)
    content.titleLeft:SetText(string.format("%s%s|r", classColor, name))

    content.titleCenter = content.titleCenter or content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.titleCenter:SetPoint("TOP", -2, -12)
    content.titleCenter:SetText("|cffffffffIcecrown|r")

    content.titleRightMain = content.titleRightMain or content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    content.titleRightMain:SetPoint("TOPRIGHT", -38, -12)
    content.titleRightMain:SetText(string.format("%s%s|r", poColor, poText))

    content.titleRightSub = content.titleRightSub or content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    content.titleRightSub:SetPoint("TOPLEFT", content.titleRightMain, "TOPRIGHT", 2, -4)
    content.titleRightSub:SetText(string.format("|cffffffff(%d)|r", rank))

    content.lines = content.lines or {}
    for _, line in ipairs(content.lines) do line:Hide() end
    wipe(content.lines)

    -- Headers
    local headers = {
        { label = "Boss", x = 20 },
        { label = "Rank", x = 210 },
        { label = "Points", x = 300 },
        { label = "Best DPS", x = 400 },
    }

    for _, col in ipairs(headers) do
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        header:SetPoint("TOPLEFT", col.x, -60)
        header:SetText("|cffFFD100" .. col.label .. "|r")
        table.insert(content.lines, header)
    end

    local yOffset = -80
    for _, bossKey in ipairs({ "lm", "ldw", "ds", "fg", "rf", "pp", "bpc", "bql", "sg", "lk" }) do
        local boss = data.b[bossKey]
        if boss then
            local nameText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            nameText:SetPoint("TOPLEFT", 20, yOffset)
            nameText:SetText(BossNameLookup[bossKey])
            table.insert(content.lines, nameText)

            local rankText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            rankText:SetPoint("TOPLEFT", 200, yOffset)
            rankText:SetJustifyH("CENTER")
            rankText:SetWidth(50)
            rankText:SetText(string.format("|cffffffff%d|r", boss.r or 0))
            table.insert(content.lines, rankText)

            local pointText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            pointText:SetPoint("TOPLEFT", 289, yOffset)
            pointText:SetJustifyH("CENTER")
            pointText:SetWidth(60)
            local pStr = boss.p == 100 and "100" or string.format("%.2f", boss.p)
            pointText:SetText(GetColorForPercentile(boss.p) .. pStr .. "|r")
            table.insert(content.lines, pointText)

            local dpsText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            dpsText:SetPoint("TOP", content, "TOPLEFT", 420, yOffset)
            dpsText:SetJustifyH("CENTER")
            dpsText:SetWidth(80)
            dpsText:SetText(FormatNumber(boss.dps))
            table.insert(content.lines, dpsText)

            yOffset = yOffset - 20
        end
    end
end

Private.CreateOrShowInfoFrame = CreateOrShowInfoFrame