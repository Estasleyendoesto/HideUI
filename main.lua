gUI = LibStub("AceAddon-3.0"):NewAddon("GhostUI", "AceEvent-3.0")
gUI:SetDefaultModuleState(false)

function gUI:OnEnable()
    self:EnableModule("Database")
    self:EnableModule("Interface")

    local db = self:GetModule("Database")
    self:OnGlobalChange(nil, "addonEnabled", db:GetGlobals().addonEnabled)

    self:RegisterMessage("GHOSTUI_GLOBAL_CHANGED", "OnGlobalChange")
end

function gUI:OnGlobalChange(_, field, value)
    if field == "addonEnabled" then
        if value then
            self:EnableModule("FrameManager")
            self:EnableModule("Events")
        else
            self:DisableModule("Events")
            self:DisableModule("FrameManager")
        end
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
