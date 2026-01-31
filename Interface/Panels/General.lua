local _, ns = ...
local General = HideUI:NewModule("General", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- INICIALIZACIÓN Y EVENTOS
---------------------------------------------------------------------
function General:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnPanelChanged")
end

function General:OnPanelChanged(message, panelName)
    if panelName == "General" then
        self:Draw()
    end
end

---------------------------------------------------------------------
-- MÉTODOS DE ESTADO
---------------------------------------------------------------------
--- Si el panel está visible, lo redibujamos para refrescar valores
function General:Refresh()
    local MainFrame = HideUI:GetModule("MainFrame")
    if MainFrame.frame:IsVisible() and self.isOpen then
        self:Draw()
    end
end

---------------------------------------------------------------------
-- RENDERIZADO DEL PANEL
---------------------------------------------------------------------
function General:Draw()
    local MainFrame   = HideUI:GetModule("MainFrame")
    local Header      = HideUI:GetModule("Header")
    local Collapsible = HideUI:GetModule("Collapsible")
    local Builder     = HideUI:GetModule("Builder")
    local Database    = HideUI:GetModule("Database")
    local Popup       = HideUI:GetModule("Popup")
    local Button      = HideUI:GetModule("Button")
    local Section     = HideUI:GetModule("Section")

    self.isOpen = true
    MainFrame.currentPanel = "General"
    MainFrame:ClearAll()

    -- Cabecera y Reset
    local header = Header:Create(MainFrame.TopPanel, "General Settings", function()
        Popup:Confirm("Are you sure you want to reset all global settings?", function()
            Database:RestoreGlobals()
            self:Draw() -- Redibujamos con los valores de fábrica
        end)
    end)
    MainFrame:RegisterHeader(header)
    Utils:VStack(MainFrame.TopPanel)

    -- Dibujado del Content
    Utils:RegisterLayout(MainFrame.Content, {
        padding = 15,
        spacing = 8
    })
    Builder:RenderSettings(MainFrame.Content, "globals")
    Utils:VStack(MainFrame.Content)
end