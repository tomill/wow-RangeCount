local frame = CreateFrame("Button", "RangeCountFrame", UIParent)
frame:SetFrameStrata("TOOLTIP")
frame:SetWidth(140)
frame:SetHeight(30)
frame:SetPoint("CENTER", 0, 0)
frame:SetMovable(true)
frame:SetUserPlaced(true)
frame:CreateTitleRegion()
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self) frame:StartMoving() end)
frame:SetScript("OnDragStop", function(self) frame:StopMovingOrSizing() end)
frame:Show()

local textarea = frame:CreateFontString("CFontString")
textarea:SetFont("Fonts\\FRIZQT__.TTF", 22, "THICKOUTLINE")
textarea:SetPoint("CENTER", frame, "CENTER", 0, 0)
textarea:SetWidth(frame:GetWidth())
textarea:SetHeight(frame:GetHeight())
textarea:SetTextColor(1, 1, 1)

frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_AURA")
frame:RegisterEvent("UNIT_POWER")
frame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
frame:RegisterEvent("UNIT_HEALTH_FREQUENT")

frame:SetScript("OnEvent", function(self, event)
    local members = GetNumGroupMembers()
    
    -- disable if death/ghost or not in group
    if (UnitHealth("player") <= 0 or UnitIsGhost("player") or members <= 0) then
        textarea:SetTextColor(1, 1, 1)
        textarea:SetText("- vs -")
        return
    end

    -- count friend members
    local party_in_range = 0
    for i = 1, members do
        local unit = "raid" .. i
        if (UnitHealth(unit) <= 0 and UnitIsGhost(unit) and UnitInRange(unit)) then
            party_in_range = party_in_range + 1
        end
    end

    -- count enemy members (by battleground target hack)
    local enemy_in_range = ""
    if RangeCount_BGTarget_Accessor == nil then
        enemy_in_range = "?"
    else
        local bgtargetframe, enemymembers = RangeCount_BGTarget_Accessor()
        enemy_in_range = 0
        for i = 1, enemymembers do
            if bgtargetframe.TargetButton[i].Background:GetAlpha() == 1 then
                enemy_in_range = enemy_in_range + 1
            end
        end
    end
    
    -- color
    if enemy_in_range ~= "?" then
        local diff = party_in_range - enemy_in_range
        if diff <= 2 then
            textarea:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
        elseif diff <= 1 then
            textarea:SetTextColor(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b)
        elseif diff >= 1 then
            textarea:SetTextColor(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        else
            textarea:SetTextColor(1, 1, 1) -- default: white
        end
    end
    
    -- display
    textarea:SetText(string.format("%s vs %s", party_in_range, enemy_in_range))
end)
