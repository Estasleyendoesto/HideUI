local Interface = HideUI:NewModule("Interface")

local Data
local Controller
local AmigableUI
local FrameInterface

local MAIN_MENU_PANEL
local GENERAL_SETTINGS_PANEL

function Interface:OnInitialize()
    Data           = HideUI:GetModule("Data")
    Controller     = HideUI:GetModule("Controller")
    FrameInterface = HideUI:GetModule("FrameInterface")
    AmigableUI     = HideUI:GetModule("AmigableUI")
end

function Interface:OnEnable()
    --Main menu
    self:MainMenu("HideUI")
    --Submenu 1
    self:GeneralSettingsMenu("General")
    --Submenu 2
    self:FrameSettingsMenu("Frames")
    --DB Update
    self:UpdateUI()
    FrameInterface:UpdateUI()
end

-------------------------------------------------------------------------------->>>
-- Update Menus
function Interface:UpdateUI()
    local panel = GENERAL_SETTINGS_PANEL
    local globals = Data:Find("globals")
    -- General
    panel.isEnabled_checkbox:SetChecked(globals.isEnabled)
    panel.globalAlphaAmount_slider:SetValue(globals.globalAlphaAmount)
    -- Mouseover
    panel.isMouseoverEnabled_checkbox:SetChecked(globals.isMouseoverEnabled)
    panel.mouseoverFadeIn_slider:SetValue(globals.mouseoverFadeInAmount)
    panel.mouseoverFadeOut_slider:SetValue(globals.mouseoverFadeOutAmount)
    -- Combat
    panel.isCombatEnabled_checkbox:SetChecked(globals.isCombatEnabled)
    -- AFK
    panel.isAFKEnabled_checkbox:SetChecked(globals.isAFKEnabled)
    --Mount
    panel.isMountEnabled_checkbox:SetChecked(globals.isMountEnabled)
    --Instance
    panel.isInstanceEnabled_checkbox:SetChecked(globals.isInstanceEnabled)
end

-------------------------------------------------------------------------------->>>
-- Menus
function Interface:MainMenu(menu_name)
    local parent = InterfaceOptionsFramePanelContainer
    local panel = CreateFrame("Frame", "HideUI" .. menu_name .. "Panel", parent)
    panel.name = menu_name
    panel.type = "Panel"
    InterfaceOptions_AddCategory(panel)
    MAIN_MENU_PANEL = panel
end

function Interface:GeneralSettingsMenu(submenu_name)
    local parent = MAIN_MENU_PANEL
    local panel = CreateFrame("Frame", "HideUI" .. submenu_name .. "Panel", parent)
    panel.name = submenu_name
    panel.type = "Panel"
    panel.parent = parent.name
    InterfaceOptions_AddCategory(panel)
    GENERAL_SETTINGS_PANEL = panel
    self:GeneralSettingsMenu_Build()
end

function Interface:FrameSettingsMenu(submenu_name)
    local parent = MAIN_MENU_PANEL
    local panel = CreateFrame("Frame", "HideUI" .. submenu_name .. "Panel", parent)
    panel.name = submenu_name
    panel.type = "Panel"
    panel.parent = parent.name
    InterfaceOptions_AddCategory(panel)
    FrameInterface:Menu_Build(panel)
end

-------------------------------------------------------------------------------->>>
-- Menu Options
function Interface:GeneralSettingsMenu_Build()
    local field
    -- Panel
    AmigableUI:ScrollBox("panel_scroll", GENERAL_SETTINGS_PANEL, true)
    AmigableUI:Header("panel_header", "General Settings")

    -- General
    AmigableUI:Title("title_1", "General")
    AmigableUI:Checkbox("isEnabled_checkbox", "Enabled", false, function(e) Controller:HandleEnabledChange(e) end)
    AmigableUI:Slider("globalAlphaAmount" .. "_slider", "Overall Transparency", 0, 1, 0.5, 0.01, function(e) Controller:HandleGlobalSettings("globalAlphaAmount", e) end)

    -- Mouseover
    AmigableUI:Title("title_2", "Mouseover Settings")
    AmigableUI:Checkbox("isMouseoverEnabled" .. "_checkbox", "Reveal on Mouseover", true, function(e) Controller:HandleGlobalSettings("isMouseoverEnabled", e) end)
    AmigableUI:Slider("mouseoverFadeIn" .. "_slider", "Fade In Duration", 0, 2, 0.5, 0.1, function(e) Controller:HandleGlobalSettings("mouseoverFadeIn", e) end)
    AmigableUI:Slider("mouseoverFadeOut" .. "_slider", "Fade Out Duration", 0, 2, 0.5, 0.1, function(e) Controller:HandleGlobalSettings("mouseoverFadeOut", e) end)

    -- Combat
    AmigableUI:Title("title_3", "Combat Settings")
    AmigableUI:Checkbox("isCombatEnabled" .. "_checkbox", "Reveal on Combat", true, function(e) Controller:HandleGlobalSettings("isCombatEnabled", e) end)

    -- AFK
    AmigableUI:Title("title_4", "AFK Settings")
    AmigableUI:Checkbox("isAFKEnabled" .. "_checkbox", "Hide on AFK", true, function(e) Controller:HandleGlobalSettings("isAFKEnabled", e) end)
    
    -- Mount Mode
    AmigableUI:Title("title_5", "Mount Settings")
    AmigableUI:Checkbox("isMountEnabled" .. "_checkbox", "Hide on Mount", true, function(e) Controller:HandleGlobalSettings("isMountEnabled", e) end)

    --Instance
    AmigableUI:Title("title_6", "Instance Settings")
    AmigableUI:Checkbox("isInstanceEnabled" .. "_checkbox", "Reveal on Instance", true, function(e) Controller:HandleGlobalSettings("isInstanceEnabled", e) end)
end