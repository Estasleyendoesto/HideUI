local FrameInterface = HideUI:NewModule("FrameInterface")
local Data
local Controller
local AmigableUI

local FRAME_SETTINGS_PANEL

local BINDINGS = {
    -- Chatbox
    {name = "Chatbox", alias = "Chat", extras="1"},
    -- Misc
    {name = "MinimapCluster", alias = "Minimap"},
    {name = "ObjectiveTrackerFrame", alias = "Quests"},
    {name = "BuffFrame", alias = "Buffs"},
    {name = "MicroMenuContainer", alias = "Menu"},
    {name = "BagsBar", alias = "Bags"},
    {name = "BattlefieldMapFrame", alias = "Zone Map"},
    {name = "EncounterBar", alias = "Dragonriding Bar"},
    {name = "PlayerCastingBarFrame", alias = "Casting Bar"},
    {name = "MainStatusTrackingBarContainer", alias = "Tracking Bar"},
    {name = "StanceBar", alias = "Stance Bar"},
    {name = "PartyFrame", alias = "Party Frame"},
    {name = "WorldFrame", alias = "World Frame"},
    -- Frames
    {name = "PlayerFrame", alias = "Player"},
    {name = "TargetFrame", alias = "Target"},
    {name = "FocusFrame", alias = "Focus"},
    {name = "PetFrame", alias = "Pet Frame"},
    -- Spell Bars
    {name = "MainMenuBar", alias = "Action Bar 1"},
    {name = "MultiBarBottomLeft", alias = "Action Bar 2"},
    {name = "MultiBarBottomRight", alias = "Action Bar 3"},
    {name = "MultiBarRight", alias = "Action Bar 4"},
    {name = "MultiBarLeft", alias = "Action Bar 5"},
    {name = "Multibar5", alias = "Action Bar 6"},
    {name = "Multibar6", alias = "Action Bar 7"},
    {name = "Multibar7", alias = "Action Bar 8"},
    {name = "PetActionBar", alias = "Pet Action Bar"},
    {name = "ZoneAbilityFrame", alias = "Zone Action Bar"},
}

function FrameInterface:OnInitialize()
    Data       = HideUI:GetModule("Data")
    Controller = HideUI:GetModule("Controller")
    AmigableUI = HideUI:GetModule("AmigableUI")
end

function FrameInterface:UpdateUI()
    local panel = FRAME_SETTINGS_PANEL
    local data = Data:Find("frames")

    for _, frame in pairs(data) do
        if frame.source == "oficial" then
            panel[frame.name].content.panel["isEnabled_checkbox"]:SetChecked(frame.isEnabled)
            panel[frame.name].content.panel["isAlphaEnabled_checkbox"]:SetChecked(frame.isAlphaEnabled)
            panel[frame.name].content.panel["alphaAmount_slider"]:SetValue(frame.alphaAmount)
            panel[frame.name].content.panel["isMouseoverEnabled_checkbox"]:SetChecked(frame.isMouseoverEnabled)
            panel[frame.name].content.panel["isCombatEnabled_checkbox"]:SetChecked(frame.isCombatEnabled)
            panel[frame.name].content.panel["isMountEnabled_checkbox"]:SetChecked(frame.isMountEnabled)
            panel[frame.name].content.panel["isAFKEnabled_checkbox"]:SetChecked(frame.isAFKEnabled)
            panel[frame.name].content.panel["isInstanceEnabled_checkbox"]:SetChecked(frame.isInstanceEnabled)

            self:UpdateExtra(frame)

            if frame.isEnabled then
                panel[frame.name]:SetBackdropBorderColor(1, 1, 0, 0.5)
            end
        end
    end
end

function FrameInterface:Menu_Build(panel)
    FRAME_SETTINGS_PANEL = panel

    -- Panel
    AmigableUI:ScrollBox("panel_scroll", FRAME_SETTINGS_PANEL, true)
    AmigableUI:Header("panel_header", "Frame Settings")

    -- Frame Settings
    for _, frame in ipairs(BINDINGS) do
        local offset = (frame.extras or 0) * 24 -- Altura adicional por cada extra
        AmigableUI:Pool(frame.name, frame.alias, 270 + offset)
        self:AttachSettings(frame.name)
    end
end

function FrameInterface:AttachSettings(frame)
    local pool = AmigableUI.lastElement

    AmigableUI:Checkbox("isEnabled_checkbox", "Custom Enabled", false, function(e)
        Controller:HandleFrameSettings(frame, "isEnabled", e)
        if e then
            pool:SetBackdropBorderColor(1, 1, 0, 0.5)
        else
            pool:SetBackdropBorderColor(1, 1, 1, 0.5)
        end
    end)
    AmigableUI:Checkbox("isAlphaEnabled_checkbox", "Custom Alpha", false, function(e) Controller:HandleFrameSettings(frame, "isAlphaEnabled", e) end)
    AmigableUI:Slider("alphaAmount_slider", "Alpha Amount", 0, 1, 0.5, 0.01, function(e) Controller:HandleFrameSettings(frame, "alphaAmount", e) end)
    AmigableUI:Checkbox("isMouseoverEnabled_checkbox", "Reveal on Mouseover", false, function(e) Controller:HandleFrameSettings(frame, "isMouseoverEnabled", e) end)
    AmigableUI:Checkbox("isCombatEnabled_checkbox", "Reveal on Combat", false, function(e) Controller:HandleFrameSettings(frame, "isCombatEnabled", e) end)
    AmigableUI:Checkbox("isAFKEnabled_checkbox", "Hide on AFK", false, function(e) Controller:HandleFrameSettings(frame, "isAFKEnabled", e) end)
    AmigableUI:Checkbox("isMountEnabled_checkbox", "Hide on Mount", false, function(e) Controller:HandleFrameSettings(frame, "isMountEnabled", e) end)
    AmigableUI:Checkbox("isInstanceEnabled_checkbox", "Reveal on Instance", false, function(e) Controller:HandleFrameSettings(frame, "isInstanceEnabled", e) end)

    self:AttachExtra(frame)

    AmigableUI.lastElement = pool
end

function FrameInterface:UpdateExtra(frame)
    local panel = FRAME_SETTINGS_PANEL
    if frame.name == "Chatbox" then
        panel[frame.name].content.panel["isTextModeEnabled_checkbox"]:SetChecked(frame.isTextModeEnabled)
    end
end

function FrameInterface:AttachExtra(frame_name)
    if frame_name == "Chatbox" then
        AmigableUI:Checkbox("isTextModeEnabled_checkbox", "Text Mode", false, function(e) Controller:HandleFrameSettings(frame_name, "isTextModeEnabled", e) end)
    end
end