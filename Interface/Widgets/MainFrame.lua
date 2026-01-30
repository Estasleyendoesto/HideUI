-- Documentación de Blizzard
-- (12.0.1.65448; unchanged since 10.2.7.54604)
-- https://www.townlong-yak.com/framexml/beta/Blizzard_Settings_Shared/Blizzard_SettingsPanelTemplates.xml

local _, ns = ...
local MainFrame = HideUI:NewModule("MainFrame", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

-- Configuración estática
local CFG = {
    WIDTH  = 620,
    HEIGHT = 520,
    TITLE  = "HideUI",
    ALPHA  = 0.02,
    TOP_OFFSET = -25,
    BORDER_COLOR = {0.5, 0.5, 0.5, 0.95}
}

function MainFrame:OnEnable()
    self:CreateMainFrame()      -- 1. Contenedor base
    self:StylizeMainFrame()     -- 2. Estética (Blizzard Look)
    self:CreateTopPanel()       -- 3. Panel superior
    self:CreateNavBar()         -- 4. Botones de navegación
    self:CreateContentScroll()  -- 5. Área de scroll
    self:NotifyOnOpen()         -- 6. Hooks de eventos

    self.frame:Hide()
end

---------------------------------------------------------------------
-- 1. CONTENEDOR PRINCIPAL
---------------------------------------------------------------------
function MainFrame:CreateMainFrame()
    local f = CreateFrame("Frame", "HideUIMainFrame", UIParent)
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
-- 2. ESTÉTICA (Fondo, Bordes y Título)
---------------------------------------------------------------------
function MainFrame:StylizeMainFrame()
    local f = self.frame

    -- Fondo oscuro con template de Blizzard
    f.Bg = CreateFrame("Frame", nil, f, "FlatPanelBackgroundTemplate")
    f.Bg:SetFrameLevel(0)
    f.Bg:SetPoint("TOPLEFT", 7, -18)
    f.Bg:SetPoint("BOTTOMRIGHT", -3, 3)

    f.Bg.Darkener = f.Bg:CreateTexture(nil, "BACKGROUND", nil, 1)
    f.Bg.Darkener:SetAllPoints()
    f.Bg.Darkener:SetColorTexture(0, 0, 0, CFG.ALPHA)

    -- Bordes modernos (NineSlice)
    f.NineSlice = CreateFrame("Frame", nil, f, "NineSlicePanelTemplate")
    f.NineSlice:SetAllPoints(f)
    Mixin(f.NineSlice, NineSlicePanelMixin)
    f.NineSlice.layoutType = "ButtonFrameTemplateNoPortrait"
    f.NineSlice:OnLoad()
    f.NineSlice:SetVertexColor(unpack(CFG.BORDER_COLOR))

    -- Título y Botón cerrar
    f.Title = f.NineSlice:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.Title:SetPoint("TOP", 0, -5)
    f.Title:SetText(CFG.TITLE)

    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButtonDefaultAnchors")
    f.CloseButton:SetScript("OnClick", function() f:Hide() end)
end

---------------------------------------------------------------------
-- 3 & 4. PANELES Y NAVEGACIÓN
---------------------------------------------------------------------
function MainFrame:CreateTopPanel()
    self.TopPanel = CreateFrame("Frame", nil, self.frame)
    self.TopPanel:SetPoint("TOPLEFT", 0, CFG.TOP_OFFSET)
    self.TopPanel:SetPoint("TOPRIGHT", 0, CFG.TOP_OFFSET)
    
    Utils:RegisterLayout(self.TopPanel, { padding = 0, spacing = 5 })
end

function MainFrame:CreateNavBar()
    local Navbar = HideUI:GetModule("Navbar")
    local nav = Navbar:Create(self.TopPanel)

    local tabs = {"About", "General", "Blizzard", "Addon"}
    for _, name in ipairs(tabs) do
        local isActive = (self.currentPanel == name)

        Navbar:AddButton(nav, name, function() 
            self.currentPanel = name
            self:SendMessage("HIDEUI_PANEL_CHANGED", name)
        end, isActive)
    end

    Utils:HStack(nav)
    Utils:VStack(self.TopPanel)
end

---------------------------------------------------------------------
-- 5. ÁREA DE CONTENIDO (Scroll)
---------------------------------------------------------------------
function MainFrame:CreateContentScroll()
    local ScrollWidget = HideUI:GetModule("Scroll")
    local scroll, content = ScrollWidget:Create(self.frame)
    
    -- Anclaje dinámico al TopPanel
    scroll:SetPoint("TOPLEFT", self.TopPanel, "BOTTOMLEFT", 0, -10)
    scroll:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -30, 15)
    
    self.ScrollFrame = scroll
    self.Content = content
end

---------------------------------------------------------------------
-- MÉTODOS PÚBLICOS Y EVENTOS
---------------------------------------------------------------------
function MainFrame:Toggle()
    self.frame:SetShown(not self.frame:IsShown())
end

function MainFrame:NotifyOnOpen()
    self.frame:SetScript("OnShow", function()
        self:SendMessage("HIDEUI_CONFIG_OPENED")
    end)
end

function MainFrame:ClearAll()
    Utils:Clear(self.TopPanel)
    Utils:Clear(self.Content)
    
    -- Al limpiar, necesitamos regenerar la barra de navegación
    self:CreateNavBar()
end