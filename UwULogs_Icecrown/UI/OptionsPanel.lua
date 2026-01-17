local _, Private = ...
local L = Private.L

local function InitDB()
    UWULogsConfig = UWULogsConfig or {}
    Private.DB = UWULogsConfig

    if type(Private.DB.minimap) ~= "table" then
        Private.DB.minimap = {}
    end
    if Private.DB.minimap.hide == nil then
        Private.DB.minimap.hide = false
    end
    if Private.DB.minimap.angle == nil then
        Private.DB.minimap.angle = 45
    end
end

local function SearchPlayer(name)
    name = string.lower(name or "")
    for _, btn in ipairs(UwULogsResultButtons) do
        btn:Hide()
    end

    if name == "" then return end
    if not UWULogsData then
        UwULogsResultButtons[1].text:SetText("|cffff0000NO DATA LOADED.|r")
        UwULogsResultButtons[1]:Show()
        return
    end

    local classMap = {
        [0] = "DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN",
        "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"
    }

    local results = {}
    for classID, specs in pairs(UWULogsData) do
        for specID, entries in pairs(specs) do
            for _, line in ipairs(entries) do
                local playerName, po, rank = string.match(line, "([^|]+)|([^|]+)|([^|]+)|")
                if playerName and string.find(string.lower(playerName), "^" .. name) then
                    table.insert(results, {
                        name = playerName,
                        classID = classID,
                        specID = specID,
                        po = tonumber(po),
                        rank = tonumber(rank)
                    })
                end
            end
        end
    end

    if #results == 0 then
        UwULogsResultButtons[1].text:SetText("|cffff0000PLAYER NOT FOUND.|r")
        UwULogsResultButtons[1]:Show()
    else
        for i, result in ipairs(results) do
            local btn = UwULogsResultButtons[i]
            if btn then
                local classFile = classMap[result.classID]
                local icon = Private.SPEC_ICONS[classFile] and Private.SPEC_ICONS[classFile][result.specID]
                local color = Private.GetColorForPercentile(result.po or 0)

                btn.text:SetText(string.format(
                    "%s%s|r - Rank: |cffffffff%d|r - Percentile: %s%d%%|r",
                    icon and ("|T"..icon..":16:16:0:0|t ") or "",
                    result.name, result.rank, color, result.po
                ))

                btn:SetScript("OnClick", function()
                    if _G.ShowUWULogsTooltipFromSearch then
                        _G.ShowUWULogsTooltipFromSearch(GameTooltip, result.name, result.classID, result.specID)
                    end
                end)
                btn:Show()
            end
        end
    end
end

local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "UWULogsOptionsPanel", UIParent)
    panel.name = "UwULogs Tooltip"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetText(L["UwULogs Tooltip"])
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetJustifyH("LEFT")
    title:SetWidth(550)

    local minimapCheckbox = CreateFrame("CheckButton", "UWULogsMinimapCheckbox", panel, "OptionsCheckButtonTemplate")
    minimapCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -32)
    _G[minimapCheckbox:GetName().."Text"]:SetText("Show minimap button")
    minimapCheckbox:SetChecked(not Private.DB.minimap.hide)

    minimapCheckbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        Private.DB.minimap.hide = not checked
        if checked then
            UwULogsMinimapButton:Show()
        else
            UwULogsMinimapButton:Hide()
        end
    end)

    local instruction = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    instruction:SetPoint("TOPLEFT", minimapCheckbox, "BOTTOMLEFT", 0, -16)
    instruction:SetText(L["Please enter a name to see if it is in the top 1000 :"])

    local searchBox = CreateFrame("EditBox", "UwULogsSearchBox", panel, "InputBoxTemplate")
    searchBox:SetSize(200, 20)
    searchBox:SetAutoFocus(false)
    searchBox:SetPoint("TOPLEFT", instruction, "BOTTOMLEFT", 4, -4)
    searchBox:SetText("")
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    searchBox:SetScript("OnEnterPressed", function(self)
        local name = self:GetText()
        SearchPlayer(name)
        self:ClearFocus()
    end)

    local resultButtons = {}
    for i = 1, 10 do
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(600, 20)
        btn:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, -20 * i)

        local font = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        font:SetJustifyH("LEFT")
        font:SetPoint("LEFT")
        font:SetWidth(600)

        btn.text = font
        btn:SetFontString(font)
        btn:Hide()

        resultButtons[i] = btn
    end

    UwULogsResultButtons = resultButtons

    local sourceText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sourceText:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 16)
    sourceText:SetText("|cff888888Data from https://uwu-logs.xyz/|r")

    panel:SetScript("OnHide", function()
        searchBox:SetText("")
        for _, btn in ipairs(UwULogsResultButtons) do
            btn.text:SetText("")
            btn:Hide()
        end
    end)

    InterfaceOptions_AddCategory(panel)
end

local function CreateMinimapButton()
    local btn = CreateFrame("Button", "UwULogsMinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetMovable(true)
    btn:RegisterForDrag("LeftButton")
    btn:RegisterForClicks("LeftButtonDown", "RightButtonDown")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\AddOns\\UwULogs_Icecrown\\Icons\\UwU_1.blp")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = icon

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(52, 52)
    border:SetPoint("CENTER", btn, "CENTER", 10, -10)

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetAllPoints(btn)
    highlight:SetBlendMode("ADD")
    btn:SetHighlightTexture(highlight)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CENTERRIGHT")
        GameTooltip:AddLine("UwULogs", 1, 1, 1)
        GameTooltip:AddLine("Hold Left-Click to drag the icon around the mini-map", 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine("Right-click to open the menu", 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            InterfaceOptionsFrame_OpenToCategory("UwULogs Tooltip")
        end
    end)

    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local dx, dy = cx - mx, cy - my
            local angle = math.deg(math.atan2(dy, dx)) % 360
            Private.DB.minimap.angle = angle
            local rad = math.rad(angle)
            local x = math.cos(rad) * 80
            local y = math.sin(rad) * 80
            btn:ClearAllPoints()
            btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- Initial placement
    local rad = math.rad(Private.DB.minimap.angle)
    local x = math.cos(rad) * 80
    local y = math.sin(rad) * 80
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)

    if Private.DB.minimap.hide then
        btn:Hide()
    end
end

local function OnPlayerLogin()
    InitDB()
    CreateMinimapButton()
    CreateOptionsPanel()
end

Private.OnPlayerLogin = OnPlayerLogin

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event)
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    OnPlayerLogin()
end)