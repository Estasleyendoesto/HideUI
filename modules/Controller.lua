local Controller = HideUI:NewModule("Controller", "AceEvent-3.0")
local Model
local Interface

function Controller:OnInitialize()
    Model = HideUI:GetModule("Model")
    Interface = HideUI:GetModule("Interface")
end

function Controller:OnEnable()
    self:ModulesHandler()
end

function Controller:OnDisable()
    self:ModulesHandler()
end

function Controller:ModulesHandler()
    if Model:Find("isEnabled") then
        HideUI:EnableModule("FrameManager")
        HideUI:EnableModule("StateManager")
    else
        HideUI:DisableModule("StateManager")
        HideUI:DisableModule("FrameManager")
    end
end

-------------------------------------------------------------------------------->>>
-- Bindings.xml
function HideUI_Enable_Keydown()
    Controller:HandleEnabledChange(not Model:Find("isEnabled"))
    Interface:UpdateUI()
end

-------------------------------------------------------------------------------->>>
-- Interface.lua - Globals
function Controller:HandleEnabledChange(checked) --Toggle All
    Model:Update("isEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleGlobalSettingsChange(operator, input)
    local field
    if operator == "ALPHA_AMOUNT" then
        field = "globalAlphaAmount"
    elseif operator == "MOUSEOVER" then
        field = "isMouseoverEnabled"
    elseif operator == "FADE_IN" then
        field = "mouseoverFadeInAmount"
        operator = "MOUSEOVER_" .. operator .. "_AMOUNT"
    elseif operator == "FADE_OUT" then
        field = "mouseoverFadeOutAmount"
        operator = "MOUSEOVER_" .. operator .. "_AMOUNT"
    end
    if field then
        Model:Update(field, input)
        self:SendMessage("GLOBAL_SETTINGS_CHANGED", operator, input)
    end
end

-------------------------------------------------------------------------------->>>
-- Interface.lua - States
function Controller:HandleStateChange(state, input)
    local field
    if state == "COMBAT" then
        field =  "isCombatEnabled"
    elseif state == "AFK" then
        field = "isAFKEnabled"
    elseif state == "MOUNT" then
        field = "isMountEnabled"
    elseif state == "INSTANCE" then
        field = "isInstanceEnabled"
    end
    if field then
        Model:Update(field, input)
        self:SendMessage("GLOBAL_SETTINGS_CHANGED", state, input)
    end
end

-------------------------------------------------------------------------------->>>
-- Interface.lua - For Frames
function Controller:HandleFrameSettingsChange(frame, field, input)
    Model:UpdateFrame(frame, field, input)
    self:SendMessage("FRAME_SETTINGS_CHANGED", frame, field, input)
end