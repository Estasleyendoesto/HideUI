local _, ns = ...
local Collapsible = HideUI:NewModule("Collapsible")
local Utils = HideUI:GetModule("Utils")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------
-- Configura las texturas y fuentes del botón (Header)
local function ApplyHeaderStyles(header, title, config)
    local offL, offR = config.headerLeft, config.headerRight

    header:SetHeight(config.headerHeight)
    
    header.Left = header:CreateTexture(nil, "BACKGROUND")
    header.Left:SetAtlas("Options_ListExpand_Left", true)
    header.Left:SetPoint("TOPLEFT", offL, 0)

    header.Right = header:CreateTexture(nil, "BACKGROUND")
    header.Right:SetAtlas("Options_ListExpand_Right", true)
    header.Right:SetPoint("TOPRIGHT", offR, 0)

    header.Mid = header:CreateTexture(nil, "BACKGROUND")
    header.Mid:SetAtlas("_Options_ListExpand_Middle", true)
    header.Mid:SetPoint("TOPLEFT", header.Left, "TOPRIGHT")
    header.Mid:SetPoint("TOPRIGHT", header.Right, "TOPLEFT")

    header.Text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header.Text:SetText(title)
    header.Text:SetPoint("LEFT", header.Left, "LEFT", 17, 0)
end

local function SetEnabledVisual(header, isEnabled)
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

    -- Icono de expansión
    local atlas = isExpanded and "Options_ListExpand_Right_Expanded" or "Options_ListExpand_Right"
    header.Right:SetAtlas(atlas, true)
    
    -- CALCULO DE ALTURA DINÁMICA
    local height = header:GetHeight()
    if isExpanded then
        height = height + content:GetHeight()
    end

    container:SetHeight(height)
    
    if container.parent then
        Utils:VStack(container.parent)
    end
end

local function CreateDeleteButton(header, onDelete, config)
    local btn = CreateFrame("Button", nil, header)
    btn:SetSize(20, 20)
    btn:SetPoint("RIGHT", header, "RIGHT", config.headerRight - 30, 0)
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
        onDelete()
    end)

    header.DeleteBtn = btn
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Collapsible:Create(parent, title, layout, onDelete)
    local config = Utils:GetLayout(layout, {
        margin = { left = 0, right = 0 },
        padding = { x = 10, y = 10 },
        spacing = 10, 
        headerLeft = 30,
        headerRight = -12, 
        headerHeight  = 25,
    })

    -- Contenedor Principal
    local container = CreateFrame("Frame", nil, parent)
    container:SetWidth(parent:GetWidth())
    container.parent = parent
    container.layoutConfig = config

    -- Header (button)
    local header = CreateFrame("Button", nil, container)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    ApplyHeaderStyles(header, title, config)
    if onDelete then CreateDeleteButton(header, onDelete, config) end
    
    -- Contenido (Frame contenedor de widgets)
    local content = CreateFrame("Frame", nil, container)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", config.margin.left, 0)
    content:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -config.margin.right, 0)
    content:Hide()

    -- Referencias internas
    container.Header  = header
    container.Content = content
    container.Content.layoutConfig = config

    -- API Pública
    function container:SetStatus(isEnabled)
        SetEnabledVisual(self.Header, isEnabled)
    end

    function container:Refresh(forceState)
        Utils:VStack(self.Content)
        UpdateCollapsibleState(self, forceState)
    end

    -- Eventos
    header:SetScript("OnClick", function() 
        container:Refresh() 
    end)

    return container
end