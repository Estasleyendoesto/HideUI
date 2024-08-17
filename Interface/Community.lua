local Community = HideUI:NewModule("Community")
local Dispatcher
local Builder
local UIManager
local Data

local MENU_NAME = "Community"
local MAPPINGS = {

}

function Community:OnInitialize()
    Dispatcher = HideUI:GetModule("Dispatcher")
    Builder = HideUI:GetModule("Builder")
    Data = HideUI:GetModule("Data")
    UIManager = HideUI:GetModule("UIManager")
end

function Community:OnEnable()
    self.registry = {}
    self:Draw()
    self:UpdateUI()
end

function Community:OnDisable()
    self.registry = nil
end

function Community:UpdateUI()
end

function Community:OnUpdate(variable, data)
end

function Community:OnDefault()
end

function Community:Draw()
end