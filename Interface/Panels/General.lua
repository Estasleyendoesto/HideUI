local _, ns = ...
local General = gUI:NewModule("General", "AceEvent-3.0")

local Database = gUI:GetModule("Database")
local Builder  = gUI:GetModule("Builder")
local Utils    = gUI:GetModule("Utils")

-- Componentes de UI
local MainFrame = gUI:GetModule("MainFrame")
local Header    = gUI:GetModule("Header")
local Popup     = gUI:GetModule("Popup")

local PANEL_NAME = "General"

---------------------------------------------------------------------
-- INICIALIZACIÓN
---------------------------------------------------------------------

function General:OnEnable()
    self:RegisterMessage("GHOSTUI_PANEL_CHANGED", "OnEnter")
end

function General:OnEnter(_, panelName)
    if panelName == PANEL_NAME then self:Draw() end
end

---------------------------------------------------------------------
-- RENDERIZADO
---------------------------------------------------------------------

function General:Draw()
    MainFrame:ClearAll()

    -- 1. Cabecera con Reset Global
    local header = Header:Create(MainFrame.TopPanel, "General Settings", function()
        Popup:Confirm("Are you sure you want to reset all global settings?", function()
            Database:RestoreGlobals()
            self:Draw()
        end)
    end)
    MainFrame:RegisterHeader(header)
    Utils:VStack(MainFrame.TopPanel)

    -- 2. Renderizado de Opciones (Categoría "globals")
    -- El tercer parámetro es nil porque no apuntamos a un frame específico
    Builder:RenderSettings(MainFrame.Content, "globals", nil, {
        padding = {x = 10, y = 10},
        titleSpacing = 10,
        spacing = 3
    })

    -- 3. Layout del Contenedor Principal
    Utils:RegisterLayout(MainFrame.Content, {
        padding = {x = 120, top = 8, bottom = 52},
        spacing = 12
    })
    Utils:VStack(MainFrame.Content)
end