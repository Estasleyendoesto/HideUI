local _, ns = ...
local Collapsible = HideUI:NewModule("Collapsible")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------

-- Configura las texturas y fuentes del botón (Header)
local function ApplyHeaderStyles(btn, title)
    local paddingL, paddingR = 30, -12
    
    -- Texturas de Blizzard (Atlas)
    local left = btn:CreateTexture(nil, "BACKGROUND")
    left:SetAtlas("Options_ListExpand_Left", true)
    left:SetPoint("TOPLEFT", paddingL, 0)

    btn.Right = btn:CreateTexture(nil, "BACKGROUND")
    btn.Right:SetAtlas("Options_ListExpand_Right", true)
    btn.Right:SetPoint("TOPRIGHT", paddingR, 0)

    local mid = btn:CreateTexture(nil, "BACKGROUND")
    mid:SetAtlas("_Options_ListExpand_Middle", true)
    mid:SetPoint("TOPLEFT", left, "TOPRIGHT")
    mid:SetPoint("TOPRIGHT", btn.Right, "TOPLEFT")

    -- Texto del título
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.Text:SetText(title)
    btn.Text:SetPoint("LEFT", paddingL + 17, 0)
end

---------------------------------------------------------------------
-- LÓGICA DE ESTADO (INTERNO)
---------------------------------------------------------------------

local function UpdateCollapsibleState(container, forceState)
    local header  = container.Header
    local content = container.Content
    
    -- Determinar si expandir o contraer
    local isExpanded = (forceState ~= nil) and forceState or not content:IsShown()
    
    content:SetShown(isExpanded)

    -- Actualizar icono (Atlas de Blizzard)
    local atlas = isExpanded and "Options_ListExpand_Right_Expanded" or "Options_ListExpand_Right"
    header.Right:SetAtlas(atlas, true)
    
    -- Recalcular altura: Header + (Contenido + Margen si está expandido)
    local height = header:GetHeight()
    if isExpanded then
        height = height + content:GetHeight() + 10
    end
    container:SetHeight(height)
    
    -- Forzar re-apilado en el frame padre
    if container.parent then
        Utils:VStack(container.parent)
    end
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------

function Collapsible:Create(parent, title, layout)
    local config = Utils:GetLayout(layout, {
        height  = 25,
        top     = -5,
        left    = 72,
        right   = -62,
        padding = 15,
        spacing = 13,
    })

    -- 1. Contenedor Principal
    local container = CreateFrame("Frame", nil, parent)
    container:SetWidth(parent:GetWidth())
    container.parent = parent
    container.layoutConfig = config

    -- 2. Header (Botón)
    local header = CreateFrame("Button", nil, container)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(config.height)
    ApplyHeaderStyles(header, title)
    
    -- 3. Contenido (Frame interno para widgets)
    local content = CreateFrame("Frame", nil, container)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", config.left, config.top)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", config.right, 0)
    content:Hide()

    -- Referencias internas
    container.Header  = header
    container.Content = content

    -- 4. Métodos del Widget
    function container:Refresh(forceState)
        -- Primero organizamos los hijos del contenido
        Utils:VStack(self.Content, config.spacing, config.padding)
        -- Luego actualizamos el estado visual del collapsible
        UpdateCollapsibleState(self, forceState)
    end

    -- 5. Eventos
    header:SetScript("OnClick", function() 
        container:Refresh() 
    end)

    return container
end