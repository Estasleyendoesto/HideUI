local Interface = HideUI:NewModule("Interface")

local Model
local Controller
local AmigableUI

local MAIN_MENU_PANEL
local GENERAL_SETTINGS_PANEL
local INDIVIDUAL_SETTINGS_PANEL

function Interface:OnInitialize()
    Model      = HideUI:GetModule("Model")
    Controller = HideUI:GetModule("Controller")
    AmigableUI = HideUI:GetModule("AmigableUI")
end

function Interface:OnEnable()
    --Main menu
    self:MainMenu("HideUI")
    --Submenu 1
    self:GeneralSettingsMenu("General")
    --DB Update
    self:UpdateUI()
end

-------------------------------------------------------------------------------->>>
-- Update Menus
function Interface:UpdateUI()
    local GS_panel = GENERAL_SETTINGS_PANEL
    -- General
    GS_panel.isEnabled_checkbox:SetChecked(Model:Find("isEnabled"))
    GS_panel.globalAlphaAmount_slider:SetValue(Model:Find("globalAlphaAmount"))
    -- Mouseover
    GS_panel.isMouseoverEnabled_checkbox:SetChecked(Model:Find("isMouseoverEnabled"))
    GS_panel.mouseoverFadeIn_slider:SetValue(Model:Find("mouseoverFadeInAmount"))
    GS_panel.mouseoverFadeOut_slider:SetValue(Model:Find("mouseoverFadeOutAmount"))
    -- Combat
    GS_panel.isCombatEnabled_checkbox:SetChecked(Model:Find("isCombatEnabled"))
    -- AFK
    GS_panel.isAFKEnabled_checkbox:SetChecked(Model:Find("isAFKEnabled"))
    --Mount
    GS_panel.isMountEnabled_checkbox:SetChecked(Model:Find("isMountEnabled"))
    --Instance
    GS_panel.isInstanceEnabled_checkbox:SetChecked(Model:Find("isInstanceEnabled"))
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

-------------------------------------------------------------------------------->>>
-- Menu Options
function Interface:GeneralSettingsMenu_Build()
    -- Panel
    AmigableUI:ScrollBox("panel_scroll", GENERAL_SETTINGS_PANEL, true)
    AmigableUI:Header("panel_header", "General Settings")

    -- General
    AmigableUI:Title("title_1", "General")
    AmigableUI:Checkbox("isEnabled_checkbox", "Enabled", false, function(e) Controller:HandleEnabledChange(e) end) 
    AmigableUI:Slider("globalAlphaAmount_slider", "Overall Transparency", 0, 1, 0.5, 0.01, function(e) Controller:HandleAlphaChange(e) end)

    -- Mouseover
    AmigableUI:Title("title_2", "Mouseover Settings")
    AmigableUI:Checkbox("isMouseoverEnabled_checkbox", "Reveal on Mouseover", true, function(e) Controller:HandleMouseoverChange(e) end)
    AmigableUI:Slider("mouseoverFadeIn_slider", "Fade In Duration", 0, 2, 0.5, 0.1, function(e) Controller:HandleMouseoverFadeAmount("FADE_IN", e) end)
    AmigableUI:Slider("mouseoverFadeOut_slider", "Fade Out Duration", 0, 2, 0.5, 0.1, function(e) Controller:HandleMouseoverFadeAmount("FADE_OUT", e) end)

    -- Combat
    AmigableUI:Title("title_3", "Combat Settings")
    AmigableUI:Checkbox("isCombatEnabled_checkbox", "Reveal on Combat", true, function(e) Controller:HandleCombatChange(e) end)

    -- AFK
    AmigableUI:Title("title_4", "AFK Settings")
    AmigableUI:Checkbox("isAFKEnabled_checkbox", "Hide on AFK", true, function(e) Controller:HandleAFKChange(e) end)
    
    -- Mount Mode
    AmigableUI:Title("title_5", "Mount Settings")
    AmigableUI:Checkbox("isMountEnabled_checkbox", "Hide on Mount", true, function(e) Controller:HandleMountChange(e) end)

    --Instance
    AmigableUI:Title("title_6", "Instance Settings")
    AmigableUI:Checkbox("isInstanceEnabled_checkbox", "Reveal on Instance", true, function(e) Controller:HandleInstanceChange(e) end)
end


--[[local Interface = HideUI:NewModule("Interface")
local Model
local Controller
local AmigableUI

local MAIN_MENU_PANEL = {}
local GENERAL_SETTINGS_PANEL = {}
local INDIVIDUAL_SETTINGS_PANEL = {}

function Interface:OnInitialize()
    Model      = HideUI:GetModule("Model")
    Controller = HideUI:GetModule("Controller")
    AmigableUI = HideUI:GetModule("AmigableUI")
end

function Interface:OnEnable()
    --Main menu
    self:MainMenu("HideUI")
    --Submenu 1
    self:GeneralSettingsMenu("General")
    self:GeneralSettingsMenu_Build()
    --Submenu 2
    self:IndividualSettingsMenu("Individual")
    self:IndividualSettingsMenu_Build()
    --DB Update
    self:UpdateUI()
end

function Interface:UpdateUI()
    local GS_panel = GENERAL_SETTINGS_PANEL
    -- General
    GS_panel.isEnabled_checkbox:SetChecked(Model:Find("isEnabled"))
    GS_panel.globalAlphaAmount_slider:SetValue(Model:Find("globalAlphaAmount"))
    -- Mouseover
    GS_panel.isMouseoverEnabled_checkbox:SetChecked(Model:Find("isMouseOverEnabled"))
    GS_panel.mouseOverFadeIn_slider:SetValue(Model:Find("mouseOverFadeInAmount"))
    GS_panel.mouseOverFadeOut_slider:SetValue(Model:Find("mouseOverFadeOutAmount"))
    -- Combat
    GS_panel.isCombatEnabled_checkbox:SetChecked(Model:Find("isCombatEnabled"))
    -- AFK
    GS_panel.isAFKEnabled_checkbox:SetChecked(Model:Find("isAFKEnabled"))
    --Mount
    GS_panel.isMountEnabled_checkbox:SetChecked(Model:Find("isMountEnabled"))
    --Chat
    GS_panel.isChatEnabled_checkbox:SetChecked(Model:Find("chatbox").isAlphaEnabled)
    GS_panel.ChatAlphaAmount_slider:SetValue(Model:Find("chatbox").alphaAmount)

    --Individual Subpanel TEST----------------------
    local IS_panel = INDIVIDUAL_SETTINGS_PANEL
    for _, frame in pairs(Model:Find("frames")) do
        if frame then
            IS_panel[frame.name .. "_isAlphaEnabled_checkbox"]:SetChecked(frame.isAlphaEnabled)
            IS_panel[frame.name .. "_alphaAmount_slider"]:SetValue(frame.alphaAmount)
        end
    end
    ------------------------------------------------
end

----------------------------------------------------------------
----------------------------------------------------------------
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
end

function Interface:IndividualSettingsMenu(submenu_name)
    local parent = MAIN_MENU_PANEL
    local panel = CreateFrame("Frame", "HideUI" .. submenu_name .. "Panel", parent)
    panel.name = submenu_name
    panel.type = "Panel"
    panel.parent = parent.name
    InterfaceOptions_AddCategory(panel)
    INDIVIDUAL_SETTINGS_PANEL = panel
end

----------------------------------------------------------------
----------------------------------------------------------------
function Interface:GeneralSettingsMenu_Build()
    -- Panel
    AmigableUI:ScrollBox("panel_scroll", GENERAL_SETTINGS_PANEL, true)
    AmigableUI:Header("panel_header", "General Settings")

    -- General
    AmigableUI:Title("title_1", "General")
    AmigableUI:Checkbox("isEnabled_checkbox", "Enabled", false, function(e) Controller:HandleEnabledChange(e) end) 
    AmigableUI:Slider("globalAlphaAmount_slider", "Overall Transparency", 0, 1, 0.5, 0.01, function(e) Controller:HandleAlphaChange(e) end)

    -- Mouseover
    AmigableUI:Title("title_2", "Mouseover Settings")
    AmigableUI:Checkbox("isMouseoverEnabled_checkbox", "Reveal on Mouseover", true, function(e) Controller:HandleMouseoverChange(e) end)
    AmigableUI:Slider("mouseOverFadeIn_slider", "Fade In Duration", 0, 2, 0.5, 0.1, function(e) Controller:HandleMouseOverFadeAmount("FADE_IN", e) end)
    AmigableUI:Slider("mouseOverFadeOut_slider", "Fade Out Duration", 0, 2, 0.5, 0.1, function(e) Controller:HandleMouseOverFadeAmount("FADE_OUT", e) end)

    -- Combat
    AmigableUI:Title("title_3", "Combat Settings")
    AmigableUI:Checkbox("isCombatEnabled_checkbox", "Reveal on Combat", true, function(e) Controller:HandleCombatChange(e) end)

    -- AFK
    AmigableUI:Title("title_4", "AFK Settings")
    AmigableUI:Checkbox("isAFKEnabled_checkbox", "Hide on AFK", true, function(e) Controller:HandleAFKChange(e) end)
    
    -- Mount Mode
    AmigableUI:Title("title_5", "Mount Settings")
    AmigableUI:Checkbox("isMountEnabled_checkbox", "Hide on Mount", true, function(e) Controller:HandleMountChange(e) end)
    
    -- Chatbox
    AmigableUI:Title("title_5", "Chat Settings")
    AmigableUI:Checkbox("isChatEnabled_checkbox", "Enable Chat Custom Transparency", true, function(e) Controller:HandleChatChange(e) end)
    AmigableUI:Slider("ChatAlphaAmount_slider", "Chat Transparency", 0, 1, 0.5, 0.01, function(e) Controller:HandleChatAlphaAmount(e) end)
end

function Interface:IndividualSettingsMenu_Build()
    --Individual Subpanel TEST----------------------
    AmigableUI:ScrollBox("scroll", INDIVIDUAL_SETTINGS_PANEL, true)
    AmigableUI:Header("header", "Individual Options")

    for _, frame in pairs(Model:Find("frames")) do
        if frame then
            AmigableUI:Checkbox(frame.name .. "_isAlphaEnabled_checkbox", frame.name .. " alpha", true, function(e) 
                Controller:HandleFrameAlpha(frame.name, e) 
            end)
            AmigableUI:Slider(frame.name .. "_alphaAmount_slider", frame.name .. " alpha amount", 0, 1, 0.5, 0.01, function(e) 
                Controller:HandleFrameAlphaAmount(frame.name, e) 
            end)
        end
    end
    ------------------------------------------------
end
 ]]