local _, ns = ...
local Blizzard = HideUI:NewModule("Blizzard", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

local MainFrame, Database, Builder, Collapsible

function Blizzard:OnEnable()
    MainFrame   = HideUI:GetModule("MainFrame")
    Database    = HideUI:GetModule("Database")
    Builder     = HideUI:GetModule("Builder")
    Collapsible = HideUI:GetModule("Collapsible")
    
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("HIDEUI_FRAME_CHANGED", "OnFrameChanged")
end

function Blizzard:OnEnter(event, panel)
    if panel == "Blizzard" then
        self:Draw()
    end
end

function Blizzard:OnFrameChanged(event, frameName, field, value)
    if field == "isEnabled" then
        local co = self.collapsibles and self.collapsibles[frameName]
        if co then
            co:SetStatus(value)
        end
    end
end

function Blizzard:Refresh()
    if MainFrame.frame:IsVisible() and self.isOpen then
        self:Draw()
    end
end

function Blizzard:TurnOn()
end

function Blizzard:TurnOff()
end

function Blizzard:Draw()
    self.isOpen = true
    MainFrame:ClearAll()

    Utils:RegisterLayout(MainFrame.Content, { padding = 15, spacing = 8 })

    self:DrawHeader()
    self:DrawFrameList()

    Utils:VStack(MainFrame.Content)
end

function Blizzard:DrawHeader()
    local Header = HideUI:GetModule("Header")
    local Popup  = HideUI:GetModule("Popup")

    Header:Create(MainFrame.TopPanel, "Blizzard Frames", function()
        Popup:Confirm("Are you sure you want to reset every frame's settings?", function()
            Database:RestoreGlobals()
            self:Draw()
        end)
    end)
    Utils:VStack(MainFrame.TopPanel)
end

function Blizzard:DrawFrameList()
    self.collapsibles = {}
    local order = ns.FRAME_REGISTRY

    for _, entry in ipairs(order) do
        local isRegistered, frame = Database:IsFrameRegistered(entry.name)
        
        -- Solo mostramos frames de origen Blizzard
        if isRegistered and frame.source == ns.SOURCE.BLIZZARD then
            local co = Collapsible:Create(MainFrame.Content, entry.alias, {
                headerLeft = 60, headerRight = -42, spacing = 3
            })

            -- Seteamos el estado del collapsible
            co:SetStatus(frame.isEnabled)
            self.collapsibles[entry.name] = co

            Builder:RenderSettings(co.Content, "frames", entry.name, {
                left = 28, right = -28, spacing = 5
            })

            co:Refresh(false)
        end
    end
end
