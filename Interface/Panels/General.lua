local _, ns = ...
local General  = gUI:NewModule("General", "AceEvent-3.0")

local Database = gUI:GetModule("Database")
local Builder  = gUI:GetModule("Builder")
local Utils    = gUI:GetModule("Utils")

-- Widgets
local MainFrame   = gUI:GetModule("MainFrame")
local Header      = gUI:GetModule("Header")
local Collapsible = gUI:GetModule("Collapsible")
local Popup       = gUI:GetModule("Popup")
local Button      = gUI:GetModule("Button")
local Section     = gUI:GetModule("Section")

-- Panel Name
local PANEL_NAME = "General"

---------------------------------------------------------------------
-- INICIALIZACIÓN Y EVENTOS
---------------------------------------------------------------------
function General:OnEnable()
    self:RegisterMessage("gUI_PANEL_CHANGED", "OnEnter")
end

function General:OnEnter(_, panelName)
    if panelName == PANEL_NAME then self:Draw() end
end

---------------------------------------------------------------------
-- RENDERIZADO DEL PANEL
---------------------------------------------------------------------
function General:Draw()
    MainFrame:ClearAll()

    -- Cabecera y Reset
    local header = Header:Create(MainFrame.TopPanel, "General Settings", function()
        Popup:Confirm("Are you sure you want to reset all global settings?", function()
            Database:RestoreGlobals()
            self:Draw()
        end)
    end)
    MainFrame:RegisterHeader(header)
    Utils:VStack(MainFrame.TopPanel)

    Builder:RenderSettings(MainFrame.Content, "globals", nil, {
        -- Ajusta cada section individual
        padding = {x = 10, y = 10},
        titleSpacing = 10,
        spacing = 3
    })

    Utils:RegisterLayout(MainFrame.Content, {
        -- Ajusta el contenedor de los sections
        padding = {x = 120, top = 8, bottom = 52},
        spacing = 12
    })
    Utils:VStack(MainFrame.Content)
end
