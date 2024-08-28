local UIManager = HideUI:NewModule("UIManager")
local General
local Blizzard
local Community

local MENU_NAME = "HideUI"

function UIManager:OnInitialize()
    General   = HideUI:GetModule("General")
    Blizzard  = HideUI:GetModule("Blizzard")
    Community = HideUI:GetModule("Community")
end

function UIManager:OnEnable()
    self:Create()

    -- HideUI:EnableModule("Welcome")
    HideUI:EnableModule("General")
    HideUI:EnableModule("Blizzard")
    HideUI:EnableModule("Community")

    self:UpdateUI()
end

function UIManager:UpdateUI()
    -- Santo remedio, como no se me había ocurrido antes
    self.isUpdating = true

    General:UpdateUI()
    Blizzard:UpdateUI()
    Community:UpdateUI()

    C_Timer.After(0.15, function()
        self.isUpdating = false
    end)
end

function UIManager:Rebuild()
    Community:Rebuild()
end

function UIManager:Toggle(choice)
    if choice then
        General:TurnOn()
        Blizzard:TurnOn()
        Community:TurnOn()
    else
        General:TurnOff()
        Blizzard:TurnOff()
        Community:TurnOff()
    end
end

function UIManager:Create()
    local parent = UIParent
    local frame = CreateFrame("Frame", "HideUI" .. MENU_NAME .. "Frame", parent)
    frame.name = MENU_NAME

    local category, layout = Settings.RegisterCanvasLayoutCategory(frame, MENU_NAME)
    Settings.RegisterAddOnCategory(category)

    self.frame = frame
    self.category = category
    self.layout = layout
end