local Blizzard = HideUI:NewModule("Blizzard")
local Dispatcher
local Builder
local UIManager
local Data

local MENU_NAME = "Frames"
local MAPPINGS = {

}

function Blizzard:OnInitialize()
    Dispatcher = HideUI:GetModule("Dispatcher")
    Builder = HideUI:GetModule("Builder")
    Data = HideUI:GetModule("Data")
    UIManager = HideUI:GetModule("UIManager")
end

function Blizzard:OnEnable()
    self.registry = {}
    self:Draw()
    self:UpdateUI()
end

function Blizzard:OnDisable()
    self.registry = nil
end

function Blizzard:UpdateUI()
end

function Blizzard:OnUpdate(variable, data)
end

function Blizzard:OnDefault()
end

function Blizzard:Draw()
end