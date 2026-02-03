local _, ns = ...
local Blizzard = gUI:NewModule("Blizzard", "AceEvent-3.0")

local Database = gUI:GetModule("Database")
local Builder  = gUI:GetModule("Builder")
local Utils    = gUI:GetModule("Utils")

-- Componentes de UI
local MainFrame   = gUI:GetModule("MainFrame")
local Collapsible = gUI:GetModule("Collapsible")
local Header      = gUI:GetModule("Header")
local Popup       = gUI:GetModule("Popup")

local PANEL_NAME = "Blizzard"

function Blizzard:OnEnable()
    self:RegisterMessage("GHOSTUI_PANEL_CHANGED", "OnEnter")
    self:RegisterMessage("GHOSTUI_FRAME_CHANGED", "OnFrameChanged")
end

-- Actualiza visualmente el check del collapsible si el estado cambia externamente
function Blizzard:OnFrameChanged(_, frameName, field, value)
    if field == "isEnabled" and self.collapsibles then
        local co = self.collapsibles[frameName]
        if co then co:SetStatus(value) end
    end
end

function Blizzard:OnEnter(_, panel)
    if panel == PANEL_NAME then self:Draw() end
end

---------------------------------------------------------------------
-- DIBUJO DE COMPONENTES
---------------------------------------------------------------------

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
    local registry = ns.FRAME_REGISTRY

    for _, entry in ipairs(registry) do
        local isRegistered, frame = Database:IsFrameRegistered(entry.name)
        
        -- Solo dibujamos si está en la DB y su origen es Blizzard
        if isRegistered and frame.source == ns.SOURCE.BLIZZARD then
            local co = Collapsible:Create(MainFrame.Content, entry.alias, {
                margin  = { left = 70, right = 40 },
                padding = { x = 10, top = 10, bottom = 20 },
            })

            co:SetStatus(frame.isEnabled)
            self.collapsibles[entry.name] = co

            -- Renderizado dinámico de las opciones del frame
            Builder:RenderSettings(co.Content, "frames", entry.name, {})
            co:Refresh(false)
        end
    end
end

---------------------------------------------------------------------
-- RENDERIZADO PRINCIPAL
---------------------------------------------------------------------

function Blizzard:Draw()
    MainFrame:ClearAll()

    self:DrawHeader()
    self:DrawFrameList()

    -- Aplicamos el layout al contenedor principal de contenido
    Utils:RegisterLayout(MainFrame.Content, { 
        padding = { x = 68, top = 18, bottom = 52 } 
    })
    Utils:VStack(MainFrame.Content)
end