HideUI = LibStub("AceAddon-3.0"):NewAddon("HideUI")
HideUI:SetDefaultModuleState(false)

function HideUI:OnEnable()
    self:EnableModule("Data")
    self:EnableModule("Controller")
    self:EnableModule("Menu")
end

function HideUI:FindModule(name)
    local module = HideUI:GetModule(name, true)
    if module and module:IsEnabled() then
        return module
    else
        return nil
    end
end