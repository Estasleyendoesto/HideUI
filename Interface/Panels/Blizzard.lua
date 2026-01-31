local _, ns = ...

local Blizzard = HideUI:NewModule("Blizzard", "AceEvent-3.0")

local Database = HideUI:GetModule("Database")
local Builder  = HideUI:GetModule("Builder")
local Utils    = HideUI:GetModule("Utils")

-- Widgets
local MainFrame   = HideUI:GetModule("MainFrame")
local Collapsible = HideUI:GetModule("Collapsible")
local Header      = HideUI:GetModule("Header")
local Popup       = HideUI:GetModule("Popup")

-- Panel Name
local PANEL_NAME = "Blizzard"

function Blizzard:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("HIDEUI_FRAME_CHANGED", "OnFrameChanged")
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

    Utils:RegisterLayout(MainFrame.Content, { padding = 15, spacing = 8 })

    self:DrawHeader()
    self:DrawFrameList()

    Utils:VStack(MainFrame.Content)
end

function Blizzard:DrawHeader()
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
        
        -- Filtramos frames de Blizzard
        if isRegistered and frame.source == ns.SOURCE.BLIZZARD then
            -- Creamos el collapsible
            local co = Collapsible:Create(MainFrame.Content, entry.alias, {
                headerLeft = 60, headerRight = -42, spacing = 3
            })

            -- Definimos el estado inicial del collapsible
            co:SetStatus(frame.isEnabled)
            self.collapsibles[entry.name] = co

            -- Se rellena el collapsible
            Builder:RenderSettings(co.Content, "frames", entry.name, {
                left = 28, right = -28, spacing = 5
            })

            co:Refresh(false)
        end
    end
end
