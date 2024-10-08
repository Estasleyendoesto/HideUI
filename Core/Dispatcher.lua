local Dispatcher = HideUI:NewModule("Dispatcher", "AceEvent-3.0")
local Data
local UIManager

function Dispatcher:OnInitialize()
    Data      = HideUI:GetModule("Data")
    UIManager = HideUI:GetModule("UIManager")
end

function Dispatcher:OnEnable()
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

    C_Timer.After(0.25, function()
        self:ModulesHandler()
    end)
    C_Timer.After(0.1, function()
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
    UIManager:Toggle(choice)
    self:ModulesHandler()
end

function Dispatcher:HandleProfileChange(choice) --ChangeProfile
    self:HandleEnabledChange(false)
    C_Timer.After(0.20, function()
        Data:ChangeProfile(choice)

        self:HandleEnabledChange(true)
        UIManager:Rebuild()

        C_Timer.After(0.10, function()
            UIManager:UpdateUI()
        end)
    end)
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
    if UIManager.isUpdating then return end

    Data:UpdateGlobals(field, input)
    self:SendMessage("GLOBAL_SETTINGS_CHANGED", field, input)
end

-------------------------------------------------------------------------------->>>
function Dispatcher:HandleFrameSettings(frame, field, input) --to FrameManager
    if UIManager.isUpdating then return end

    Data:UpdateFrame(frame, field, input)
    self:SendMessage("FRAME_SETTINGS_CHANGED", frame, field)
end

-------------------------------------------------------------------------------->>>
function Dispatcher:OnFrameRegister(name)
    local input
    local data = Data:Find("frames")
    local frame = _G[name]
    local Manager = HideUI:GetModule("FrameManager")
    if frame and frame.GetName and not data[name] then
        input = {
            name = name
        }
        Data:RegisterFrame(input)
        Manager:BindFrame(name)
        return true
    end
    return false
end

function Dispatcher:OnFrameUnregister(name)
    local data = Data:Find("frames")
    local frame = data[name]
    local Manager = HideUI:GetModule("FrameManager")
    if frame and frame.source == "community" then
        Data:UnregisterFrame(name)
        Manager:UnbindFrame(name)
        return true
    end
    return false
end