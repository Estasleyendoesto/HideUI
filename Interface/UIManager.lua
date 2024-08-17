local UIManager = HideUI:NewModule("UIManager")
local General
local Blizzard

local MENU_NAME = "HideUI"

function UIManager:OnInitialize()
    General = HideUI:GetModule("General")
    Blizzard = HideUI:GetModule("Blizzard")
end

function UIManager:OnEnable()
    self:Create()
    
    -- HideUI:EnableModule("Welcome")
    HideUI:EnableModule("General")
    HideUI:EnableModule("Blizzard")
    -- HideUI:EnableModule("Community")

    self:UpdateUI()
end

function UIManager:UpdateUI()
    General:UpdateUI()
    Blizzard:UpdateUI()
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