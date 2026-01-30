local _, ns = ...
local Utils = HideUI:NewModule("Utils")

---------------------------------------------------------------------
-- CONFIGURACIÓN Y LAYOUT
---------------------------------------------------------------------

-- Normaliza nombres de parámetros (ej: h -> height)
function Utils:SetLayout(config)
    config = config or {}
    return {
        width      = config.width  or config.w,
        height     = config.height or config.h,
        x          = config.posX   or config.x,
        y          = config.posY   or config.y,
        point      = config.point  or "TOPLEFT",
        relativeTo = config.relativeTo or config.relTo,
        relPoint   = config.relativePoint or config.relPoint or "TOPLEFT",
        padding    = config.padding,
        spacing    = config.spacing,
        opacity    = config.opacity
    }
end

-- Mezcla el layout actual con valores por defecto locales
function Utils:GetLayout(layout, defaults)
    layout = layout or {}
    for key, value in pairs(defaults) do
        if layout[key] == nil then
            layout[key] = value
        end
    end
    return layout
end

-- Asigna la config al frame
function Utils:RegisterLayout(frame, layout)
    frame.layoutConfig = layout
end

---------------------------------------------------------------------
-- VSTACK: Apilado Vertical
---------------------------------------------------------------------
function Utils:VStack(container, spacing, padding)
    local cfg = Utils:GetLayout(container.layoutConfig, { padding = 15, spacing = 10 })
    
    padding = padding or cfg.padding
    spacing = spacing or cfg.spacing

    local lastChild = nil
    local totalHeight = padding

    for _, child in ipairs({ container:GetChildren() }) do
        if child:IsObjectType("Frame") and child:IsShown() then
            child:ClearAllPoints()
            
            if not lastChild then
                child:SetPoint("TOPLEFT", container, "TOPLEFT", 10, -padding)
                child:SetPoint("TOPRIGHT", container, "TOPRIGHT", -10, -padding)
            else
                child:SetPoint("TOPLEFT", lastChild, "BOTTOMLEFT", 0, -spacing)
                child:SetPoint("TOPRIGHT", lastChild, "BOTTOMRIGHT", 0, -spacing)
            end
            
            lastChild = child
            totalHeight = totalHeight + child:GetHeight() + spacing
        end
    end

    container:SetHeight(totalHeight + padding)
end

---------------------------------------------------------------------
-- HSTACK: Apilado Horizontal
---------------------------------------------------------------------
function Utils:HStack(container, spacing, padding)
    local cfg = Utils:GetLayout(container.layoutConfig, { padding = 10, spacing = 8 })
    
    padding = padding or cfg.padding
    spacing = spacing or cfg.spacing

    local lastChild = nil
    local totalWidth = padding 

    for _, child in ipairs({ container:GetChildren() }) do
        if child:IsObjectType("Frame") and child:IsShown() then
            child:ClearAllPoints()
            
            if not lastChild then
                child:SetPoint("LEFT", container, "LEFT", padding, 0)
            else
                child:SetPoint("LEFT", lastChild, "RIGHT", spacing, 0)
            end
            
            lastChild = child
            totalWidth = totalWidth + child:GetWidth() + spacing
        end
    end

    container:SetWidth(totalWidth + padding)
end

---------------------------------------------------------------------
-- MISCELÁNEA
---------------------------------------------------------------------

function Utils:DrawBackground(frame, color)
    if not frame then return end
    frame.bg = frame.bg or frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(unpack(color or {1, 1, 1, 0.03}))
end

function Utils:Clear(frame)
    if not frame then return end
    
    for _, child in ipairs({ frame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
end