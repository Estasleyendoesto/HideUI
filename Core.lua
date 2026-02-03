local _, ns = ...
gUI = LibStub("AceAddon-3.0"):NewAddon("GhostUI", "AceEvent-3.0")
gUI:SetDefaultModuleState(false)

function gUI:OnEnable()
    self:EnableModule("Database")
    self:EnableModule("Interface")
    self:EnableModule("Commands")

    local db = self:GetModule("Database")
    local enabled = db:GetGlobals().addonEnabled

    self:ToggleModules(enabled)
    self:RegisterMessage("GHOSTUI_GLOBAL_CHANGED", "OnGlobalChange")
end

function gUI:OnGlobalChange(_, field, value)
    if field == "addonEnabled" then
        self:ToggleModules(value)
    end
end

function gUI:ToggleModules(enabled)
    if enabled then
        self:EnableModule("Events")
        self:EnableModule("FrameManager")
    else
        self:DisableModule("Events")
        self:DisableModule("FrameManager")
    end
end

function gUI:FindModule(name)
    local module = gUI:GetModule(name, true)
    if module and module:IsEnabled() then
        return module
    else
        return nil
    end
end