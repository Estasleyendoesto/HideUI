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

function Controller:HandleGlobalSettings(field, input)
    Model:Update(field, input)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", field, input)
end

-------------------------------------------------------------------------------->>>
-- Interface.lua - For Frames
function Controller:HandleFrameSettings(frame, field, input)
    Model:UpdateFrame(frame, field, input)
    self:SendMessage("FRAME_SETTINGS_CHANGED", frame, field, input)
end