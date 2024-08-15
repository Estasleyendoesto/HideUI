local Controller = HideUI:NewModule("Controller", "AceEvent-3.0")
local Data
local Menu

function Controller:OnInitialize()
    Data = HideUI:GetModule("Data")
    Menu = HideUI:GetModule("Menu")
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
    Menu:UpdateUI()
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
-- FrameInterface.lua - For Frames
-- ThirdPartyInterface.lua - For Third Parties
function Controller:HandleFrameSettings(frame, field, input)
    Data:UpdateFrame(frame, field, input)
    self:SendMessage("FRAME_SETTINGS_CHANGED", frame, field)
end

-------------------------------------------------------------------------------->>>
-- ThirdPartyInterface.lua
function Controller:RegisterFrame(name)
    local data = Data:Find("frames")
    data[name] = {
        name = name,
        source = "third_party",
        alphaAmount = 0.5,
        isEnabled = false,
        isAlphaEnabled = false,
        isCombatEnabled = true,
        isAFKEnabled = true,
        isMountEnabled = true,
        isMouseoverEnabled = true,
        isInstanceEnabled = true,
    }

    local mod = HideUI:GetModule("FrameManager")
    mod:BindFrame(name)
end

function Controller:UnregisterFrame(name)
    local data = Data:Find("frames")
    data[name] = nil

    local mod = HideUI:GetModule("FrameManager")
    mod:UnbindFrame(name)
end