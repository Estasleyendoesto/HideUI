local _, ns = ...
local Blizzard = gUI:NewModule("Blizzard", "AceEvent-3.0")

local Database = gUI:GetModule("Database")
local Builder  = gUI:GetModule("Builder")
local Utils    = gUI:GetModule("Utils")

-- Widgets
local MainFrame   = gUI:GetModule("MainFrame")
local Collapsible = gUI:GetModule("Collapsible")
local Header      = gUI:GetModule("Header")
local Popup       = gUI:GetModule("Popup")

-- Panel Name
local PANEL_NAME = "Blizzard"

function Blizzard:OnEnable()
    self:RegisterMessage("gUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("gUI_FRAME_CHANGED", "OnFrameChanged")
end

function Blizzard:OnEnter(event, panel)
    if panel == PANEL_NAME then self:Draw() end
end

function Blizzard:OnFrameChanged(event, frameName, field, value)
    -- Necesario obtener el cambio de estado de un frame
    -- Para actualizar el estado del collapsible
    if field == "isEnabled" then
        local co = self.collapsibles and self.collapsibles[frameName]
        if co then
            co:SetStatus(value)
        end
    end
end

function Blizzard:Draw()
    MainFrame:ClearAll()

    self:DrawHeader()
    self:DrawFrameList()

    Utils:RegisterLayout(MainFrame.Content, { 
        -- El contenedor de los collapsibles
        padding = {x = 68, top = 18, bottom = 52} 
    })
    Utils:VStack(MainFrame.Content)
end

function Blizzard:DrawHeader()
    Header:Create(MainFrame.TopPanel, "Blizzard Frames", function()
        Popup:Confirm("Are you sure you want to reset every frame's settings?", function()
            Database:RestoreBlizzFrames()
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
        
        if isRegistered and frame.source == ns.SOURCE.BLIZZARD then
            local co = Collapsible:Create(MainFrame.Content, entry.alias, {
                -- Layout de cada collapsible
                margin  = { left = 70, right = 40 },
                padding = { x = 10, top = 10, bottom = 20 },
            })

            -- Estado inicial del collapsible
            co:SetStatus(frame.isEnabled)
            self.collapsibles[entry.name] = co

            Builder:RenderSettings(co.Content, "frames", entry.name, {
                -- Layout de cada section dentro del collapsible
            })
            co:Refresh(false)
        end
    end
end

