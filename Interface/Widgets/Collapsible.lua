local _, ns = ...
local Collapsible = HideUI:NewModule("Collapsible")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------

-- Configura las texturas y fuentes del botón (Header)
local function ApplyHeaderStyles(header, title, config)
    local paddingL, paddingR = config.headerLeft, config.headerRight
    
    -- Guardamos las 3 texturas en el botón para acceder a ellas luego
    header.Left = header:CreateTexture(nil, "BACKGROUND")
    header.Left:SetAtlas("Options_ListExpand_Left", true)
    header.Left:SetPoint("TOPLEFT", paddingL, 0)

    header.Right = header:CreateTexture(nil, "BACKGROUND")
    header.Right:SetAtlas("Options_ListExpand_Right", true)
    header.Right:SetPoint("TOPRIGHT", paddingR, 0)

    header.Mid = header:CreateTexture(nil, "BACKGROUND")
    header.Mid:SetAtlas("_Options_ListExpand_Middle", true)
    header.Mid:SetPoint("TOPLEFT", header.Left, "TOPRIGHT")
    header.Mid:SetPoint("TOPRIGHT", header.Right, "TOPLEFT")

    header.Text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header.Text:SetText(title)
    header.Text:SetPoint("LEFT", paddingL + 17, 0)
end

local function SetEnabledVisual(header, isEnabled)
    -- Si está activado, un verde brillante; si no, blanco normal (1, 1, 1)
    local r, g, b = isEnabled and 0 or 1, 1, isEnabled and 0 or 1
    
    header.Left:SetVertexColor(r, g, b)
    header.Mid:SetVertexColor(r, g, b)
    header.Right:SetVertexColor(r, g, b)
end

---------------------------------------------------------------------
-- LÓGICA DE ESTADO (INTERNO)
---------------------------------------------------------------------

local function UpdateCollapsibleState(container, forceState)
    local header  = container.Header
    local content = container.Content
    
    -- Determinar si expandir o contraer
    local isExpanded
    if forceState ~= nil then
        isExpanded = forceState
    else
        isExpanded = not content:IsShown()
    end
    
    content:SetShown(isExpanded)

    -- Actualizar icono (Atlas de Blizzard)
    local atlas = isExpanded and "Options_ListExpand_Right_Expanded" or "Options_ListExpand_Right"
    header.Right:SetAtlas(atlas, true)
    
    -- RECALCULAR ALTURA
    -- Si no está expandido, la altura es SOLO la del header
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

local function CreateDeleteButton(header, onDelete)
    if not onDelete then return end

    local btn = CreateFrame("Button", nil, header)
    btn:SetSize(20, 20)
    btn:SetPoint("RIGHT", header, "RIGHT", -72, 0)
    btn:SetFrameLevel(header:GetFrameLevel() + 10)

    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER")
    text:SetText("del")
    text:SetTextColor(1, 1, 1, 0.5) 
    btn.Text = text

    btn:SetScript("OnEnter", function(self) 
        self.Text:SetTextColor(1, 1, 1, 1)
    end)
    
    btn:SetScript("OnLeave", function(self) 
        self.Text:SetTextColor(1, 1, 1, 0.5) 
    end)

    btn:SetScript("OnMouseDown", function(self) self.Text:SetPoint("CENTER", 1, -1) end)
    btn:SetScript("OnMouseUp", function(self) self.Text:SetPoint("CENTER", 0, 0) end)

    btn:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        onDelete()
    end)

    header.DeleteBtn = btn
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------

function Collapsible:Create(parent, title, layout, onDelete)
    local config = Utils:GetLayout(layout, {
        height  = 25,
        top     = -5,
        left    = 72,
        right   = -62,
        padding = 15,
        spacing = 13,
        headerLeft = 30,
        headerRight = -12,
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
    ApplyHeaderStyles(header, title, config)
    CreateDeleteButton(header, onDelete)
    
    -- 3. Contenido (Frame interno para widgets)
    local content = CreateFrame("Frame", nil, container)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", config.left, config.top)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", config.right, 0)
    content:Hide()

    -- Referencias internas
    container.Header  = header
    container.Content = content

    -- API Pública
    function container:SetStatus(isEnabled)
        SetEnabledVisual(self.Header, isEnabled)
    end

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