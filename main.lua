HideUI = LibStub("AceAddon-3.0"):NewAddon("HideUI")
HideUI:SetDefaultModuleState(false)

function HideUI:OnEnable()
    self:EnableModule("Data")
    self:EnableModule("Dispatcher")
    self:EnableModule("UIManager")
end

function HideUI:FindModule(name)
    local module = HideUI:GetModule(name, true)
    if module and module:IsEnabled() then
        return module
    else
        return nil
    end
end