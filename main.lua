gUI = LibStub("AceAddon-3.0"):NewAddon("GhostUI")
gUI:SetDefaultModuleState(false)

function gUI:OnEnable()
    self:EnableModule("Database")
    -- self:EnableModule("Dispatcher")
    self:EnableModule("Interface")
end

function gUI:FindModule(name)
    local module = gUI:GetModule(name, true)
    if module and module:IsEnabled() then
        return module
    else
        return nil
    end
end
