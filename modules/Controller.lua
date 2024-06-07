local Controller = HideUI:NewModule("Controller", "AceEvent-3.0")
local Interface
local Data

function Controller:OnInitialize()
    Interface = HideUI:GetModule("Interface")
    Data = HideUI:GetModule("Data")
end

function Controller:OnEnable()
    self:ModulesHandler()
end

function Controller:OnDisable()
    self:ModulesHandler()
end

function Controller:ModulesHandler()
    local isEnabled = Data:Find("globals").isEnabled
    if isEnabled then
        HideUI:EnableModule("FrameManager")
        HideUI:EnableModule("EventManager")
    else
        HideUI:DisableModule("EventManager")
        HideUI:DisableModule("FrameManager")
    end
end

-------------------------------------------------------------------------------->>>
-- Bindings.xml
function HideUI_Enable_Keydown()
    local isEnabled = Data:Find("globals").isEnabled
    Controller:HandleEnabledChange(not isEnabled)
    Interface:UpdateUI()
end

-------------------------------------------------------------------------------->>>
-- Interface.lua - Globals
function Controller:HandleEnabledChange(checked) --Toggle All
    Data:UpdateGlobals("isEnabled", checked)
    self:ModulesHandler()
end

function Controller:HandleGlobalSettings(field, input)
    Data:UpdateGlobals(field, input)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", field, input)
end

-------------------------------------------------------------------------------->>>
-- Interface.lua - For Frames
function Controller:HandleFrameSettings(frame, field, input)
    Data:UpdateFrame(frame, field, input)
    self:SendMessage("FRAME_SETTINGS_CHANGED", frame, field)
end