local _, ns = ...
local MainFrame = gUI:NewModule("MainFrame", "AceEvent-3.0")
local Utils = gUI:GetModule("Utils")
local Database = gUI:GetModule("Database")

local CFG = {
    WIDTH  = 620,
    HEIGHT = 620,
    TITLE  = "GhostUI",
    ALPHA  = 0.02,
    TOP_OFFSET = -25,
    BORDER_COLOR = {0.5, 0.5, 0.5, 0.95}
}

function MainFrame:OnEnable()
    self:CreateMainFrame()      -- 1. Contenedor base
    self:StylizeMainFrame()     -- 2. Estética (Blizzard Look)
    self:CreateTopPanel()       -- 3. Panel superior
    self:CreateContentScroll()  -- 4. Área de scroll
    self:NotifyOnOpen()         -- 5. Hooks de eventos

    self.frame:Hide()
end

---------------------------------------------------------------------
-- CONTENEDOR PRINCIPAL
---------------------------------------------------------------------

function MainFrame:CreateMainFrame()
    local f = CreateFrame("Frame", "GhostUIMainFrame", UIParent)
    f:SetSize(CFG.WIDTH, CFG.HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    
    -- Movilidad
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    self.frame = f
end

---------------------------------------------------------------------
-- ESTÉTICA (Fondo y Bordes)
---------------------------------------------------------------------

function MainFrame:StylizeMainFrame()
    local f = self.frame

    -- Fondo oscuro
    f.Bg = CreateFrame("Frame", nil, f, "FlatPanelBackgroundTemplate")
    f.Bg:SetFrameLevel(0)
    f.Bg:SetPoint("TOPLEFT", 7, -18)
    f.Bg:SetPoint("BOTTOMRIGHT", -3, 3)

    f.Bg.Darkener = f.Bg:CreateTexture(nil, "BACKGROUND", nil, 1)
    f.Bg.Darkener:SetAllPoints()
    f.Bg.Darkener:SetColorTexture(0, 0, 0, CFG.ALPHA)

    -- Bordes modernos de Blizzard (NineSlice)
    f.NineSlice = CreateFrame("Frame", nil, f, "NineSlicePanelTemplate")
    f.NineSlice:SetAllPoints(f)
    Mixin(f.NineSlice, NineSlicePanelMixin)
    f.NineSlice.layoutType = "ButtonFrameTemplateNoPortrait"
    f.NineSlice:OnLoad()
    f.NineSlice:SetVertexColor(unpack(CFG.BORDER_COLOR))

    -- Título
    f.Title = f.NineSlice:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.Title:SetPoint("TOP", 0, -5)
    f.Title:SetText(CFG.TITLE)

    -- Botón cerrar
    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonDefaultAnchors")
    f.CloseButton:SetScript("OnClick", function() f:Hide() end)
end

---------------------------------------------------------------------
-- NAVEGACIÓN Y PANELES
---------------------------------------------------------------------

function MainFrame:CreateTopPanel()
    self.TopPanel = CreateFrame("Frame", nil, self.frame)
    self.TopPanel:SetPoint("TOPLEFT", 0, CFG.TOP_OFFSET)
    self.TopPanel:SetPoint("TOPRIGHT", 0, CFG.TOP_OFFSET)
    
    Utils:RegisterLayout(self.TopPanel, { 
        padding = {top = 3, bottom = 5, left = 28, right = 28}, 
        spacing = 10 
    })
end

function MainFrame:CreateNavBar()
    local Navbar = gUI:GetModule("Navbar")
    self.nav = Navbar:Create(self.TopPanel)

    local addonEnabled = Database:GetGlobals().addonEnabled
    local tabs = {"About", "General", "Blizzard", "Others"}

    for _, name in ipairs(tabs) do
        local isActive = (self.currentPanel == name)
        Navbar:AddButton(self.nav, name, function() 
            self:OpenPanel(name)
        end, isActive)
    end

    Navbar:SetEnabled(self.nav, addonEnabled)
    Navbar:Refresh(self.nav, "CENTER")
end

---------------------------------------------------------------------
-- ÁREA DE CONTENIDO
---------------------------------------------------------------------

function MainFrame:CreateContentScroll()
    local ScrollWidget = gUI:GetModule("Scroll")
    local scroll, content = ScrollWidget:Create(self.frame)
    
    -- Anclaje dinámico
    scroll:SetPoint("TOPLEFT", self.TopPanel, "BOTTOMLEFT", 0, -10)
    scroll:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -30, 15)
    
    self.ScrollFrame = scroll
    self.Content = content
end

---------------------------------------------------------------------
-- API PÚBLICA
---------------------------------------------------------------------

function MainFrame:Toggle()
    self.frame:SetShown(not self.frame:IsShown())
end

function MainFrame:OpenPanel(panelName)
    self.currentPanel = panelName
    self:ClearAll()
    self:SendMessage("GHOSTUI_PANEL_CHANGED", panelName)
end

-- Actualiza la UI cuando el addon se activa/desactiva globalmente
function MainFrame:UpdateUIVisuals(addonEnabled)
    local Navbar = gUI:GetModule("Navbar")
    
    if self.nav then
        Navbar:SetEnabled(self.nav, addonEnabled)
    end
    if self.currentHeader then
        self.currentHeader:SetEnabled(addonEnabled)
    end
end

-- Permite a los módulos registrar su cabecera para controlarla globalmente
function MainFrame:RegisterHeader(headerFrame)
    self.currentHeader = headerFrame
    local addonEnabled = Database:GetGlobals().addonEnabled
    headerFrame:SetEnabled(addonEnabled)
end

---------------------------------------------------------------------
-- LÓGICA INTERNA
---------------------------------------------------------------------

function MainFrame:NotifyOnOpen()
    self.frame:SetScript("OnShow", function()
        -- Al abrir, cargamos el panel por defecto (definido en el módulo Interface)
        gUI:GetModule("Interface"):SetupInitialPanel()
    end)
end

function MainFrame:ClearAll()
    -- Usamos el Utils:Clear que definimos para ocultar y liberar hijos
    Utils:Clear(self.TopPanel)
    Utils:Clear(self.Content)
    
    self.currentHeader = nil
    self:CreateNavBar() -- Re-creamos la navegación en el TopPanel limpio
end