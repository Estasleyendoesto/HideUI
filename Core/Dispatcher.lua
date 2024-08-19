local Dispatcher = HideUI:NewModule("Dispatcher", "AceEvent-3.0")
local Data
local UIManager

function Dispatcher:OnInitialize()
    Data      = HideUI:GetModule("Data")
    UIManager = HideUI:GetModule("UIManager")
end

function Dispatcher:OnEnable()
    Data:ChangeProfile() --Asigna el perfil seleccionado
    self:ModulesHandler()
end

function Dispatcher:OnDisable()
    self:ModulesHandler()
end

function Dispatcher:ModulesHandler()
    local isEnabled = Data:Find("globals").isEnabled
    if isEnabled then
        HideUI:EnableModule("FrameManager")
        HideUI:EnableModule("EventManager")
    else
        HideUI:DisableModule("EventManager")
        HideUI:DisableModule("FrameManager")
    end
end

function Dispatcher:Refresh()
    HideUI:DisableModule("EventManager")
    HideUI:DisableModule("FrameManager")

    C_Timer.After(0.5, function()
        self:ModulesHandler()
    end)
    C_Timer.After(0.225, function()
        UIManager:UpdateUI()
    end)
end

-------------------------------------------------------------------------------->>>
-- Bindings.xml
function HideUI_Enable_Keydown()
    local isEnabled = Data:Find("globals").isEnabled
    Dispatcher:HandleEnabledChange(not isEnabled)
    UIManager:UpdateUI()
end

-------------------------------------------------------------------------------->>>
-- General.lua
function Dispatcher:HandleEnabledChange(choice) --Toggle All
    Data:UpdateGlobals("isEnabled", choice)
    self:ModulesHandler()
end

function Dispatcher:HandleProfileChange(choice) --ChangeProfile
    local wasEnabled = Data:Find("globals").isEnabled

    self:HandleEnabledChange(false)
    Data:SetCharacterProfile(choice)
    Data:ChangeProfile()
    self:HandleEnabledChange(wasEnabled)

    self:Refresh()
end

function Dispatcher:HandleRestoreGlobals() --From General
    Data:RestoreGlobals()
    self:Refresh()
end

function Dispatcher:HandleRestoreBlizzardFrames() --From Blizzard
    Data:RestoreBlizzardFrames()
    self:Refresh()
end

function Dispatcher:HandleRestoreCommunityFrames()
    Data:RestoreCommunityFrames()
    self:Refresh()
end

function Dispatcher:HandleGlobalSettings(field, input) --to FrameManager
    Data:UpdateGlobals(field, input)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", field, input)
end

-------------------------------------------------------------------------------->>>
function Dispatcher:HandleFrameSettings(frame, field, input) --to FrameManager
    Data:UpdateFrame(frame, field, input)
    self:SendMessage("FRAME_SETTINGS_CHANGED", frame, field)
end

-------------------------------------------------------------------------------->>>
function Dispatcher:OnFrameRegister(name)
    local input
    local frame = _G[name]
    local data = Data:Find("frames")
    local manager = HideUI:GetModule("FrameManager")
    if frame and not data[name] then
        input = {
            name = name
        }
        Data:RegisterFrame(input)
        manager:BindFrame(name)
        return true
    end
    return false
end

function Dispatcher:OnFrameUnregister(name)
    local data = Data:Find("frames")
    local frame = data[name]
    local manager = HideUI:GetModule("FrameManager")
    if frame and frame.source == "community" then
        Data:UnregisterFrame(name)
        manager:UnbindFrame(name)
        return true
    end
    return false
end