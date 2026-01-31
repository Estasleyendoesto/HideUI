-- Documentación de Blizzard
-- (12.0.1.65448; unchanged since 10.2.7.54604)
-- https://www.townlong-yak.com/framexml/beta/Blizzard_Settings_Shared/Blizzard_SettingsPanelTemplates.xml

local _, ns = ...
local MainFrame = HideUI:NewModule("MainFrame", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")
local Database = HideUI:GetModule("Database")

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
    self:RegisterMessage("HIDEUI_GLOBAL_CHANGED", "OnGlobalSettingChanged")

    self.frame:Hide()
end

---------------------------------------------------------------------
-- CONTENEDOR PRINCIPAL
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
-- ESTÉTICA (Fondo, Bordes y Título)
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
-- PANELES Y NAVEGACIÓN
---------------------------------------------------------------------
function MainFrame:CreateTopPanel()
    self.TopPanel = CreateFrame("Frame", nil, self.frame)
    self.TopPanel:SetPoint("TOPLEFT", 0, CFG.TOP_OFFSET)
    self.TopPanel:SetPoint("TOPRIGHT", 0, CFG.TOP_OFFSET)
    
    Utils:RegisterLayout(self.TopPanel, { padding = 0, spacing = 5 })
end

function MainFrame:CreateNavBar()
    local Navbar = HideUI:GetModule("Navbar")
    self.nav = Navbar:Create(self.TopPanel)

    local addonEnabled = Database:GetGlobals().addonEnabled
    local tabs = {"About", "General", "Blizzard", "Others"}

    for _, name in ipairs(tabs) do
        local isActive = (self.currentPanel == name)
        Navbar:AddButton(self.nav, name, function() 
            self.currentPanel = name
            self:SendMessage("HIDEUI_PANEL_CHANGED", name)
        end, isActive)
    end

    Navbar:SetEnabled(self.nav, addonEnabled)
    Navbar:Refresh(self.nav, "CENTER")
end

function MainFrame:RegisterHeader(headerFrame)
    self.currentHeader = headerFrame
    local addonEnabled = Database:GetGlobals().addonEnabled
    headerFrame:SetEnabled(addonEnabled)
end

---------------------------------------------------------------------
-- ÁREA DE CONTENIDO (Scroll)
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
        local addonEnabled = Database:GetGlobals().addonEnabled
        local target = addonEnabled and "About" or "General"

        self.currentPanel = target
        
        self:ClearAll() 
        self:SendMessage("HIDEUI_PANEL_CHANGED", target)
    end)
end

function MainFrame:ClearAll()
    Utils:Clear(self.TopPanel)
    Utils:Clear(self.Content)
    self.currentHeader = nil
    self:CreateNavBar()
end

---------------------------------------------------------------------
-- GESTIÓN DE ESTADO GLOBAL
---------------------------------------------------------------------
function MainFrame:OnGlobalSettingChanged(message, field, value)
    if field == "addonEnabled" then
        self:UpdateUIVisuals(value)
        
        if value == false and self.currentPanel ~= "General" then
            self.currentPanel = "General"
            self:SendMessage("HIDEUI_PANEL_CHANGED", "General")
        end
    end
end

function MainFrame:UpdateUIVisuals(addonEnabled)
    local Navbar = HideUI:GetModule("Navbar")
    
    if self.nav then
        Navbar:SetEnabled(self.nav, addonEnabled)
    end
    if self.currentHeader then
        self.currentHeader:SetEnabled(addonEnabled)
    end
end