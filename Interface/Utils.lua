local _, ns = ...
local Utils = HideUI:NewModule("Utils")

---------------------------------------------------------------------
-- CONFIGURACIÓN Y LAYOUT
---------------------------------------------------------------------

-- Función auxiliar para estandarizar el padding
function Utils:NormalizePadding(p, default)
    default = default or 10
    if type(p) == "number" then
        return { top = p, bottom = p, left = p, right = p }
    elseif type(p) == "table" then
        return {
            top    = p.top    or default,
            bottom = p.bottom or default,
            left   = p.left   or default,
            right  = p.right  or default
        }
    end
    return { 
        top = default, 
        bottom = default, 
        left = default, 
        right = default 
    }
end

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
        padding    = self:NormalizePadding(config.padding or config.p),
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
    local cfg = Utils:GetLayout(container.layoutConfig or {}, { 
        spacing = 10, 
        padding = { top = 15, bottom = 15, left = 10, right = 10 } 
    })

    local spacing = spacing or cfg.spacing
    local padding = self:NormalizePadding(padding or cfg.padding)
    

    local lastChild = nil
    local totalHeight = padding.top

    local children = { container:GetChildren() }
    for i, child in ipairs(children) do
        if child:IsObjectType("Frame") and child:IsShown() then
            child:ClearAllPoints()
            
            local rel = lastChild or container
            local point = lastChild and "BOTTOM" or "TOP"
            local yOffset = lastChild and -spacing or -padding.top

            local cAlign = child.customAlign
            if cAlign then
                local align = cAlign.alignment or "CENTER"
                
                if align == "RIGHT" then
                    child:SetPoint("TOPRIGHT", rel, point .. "RIGHT", cAlign.x or -padding.right, yOffset)
                elseif align == "LEFT" then
                    child:SetPoint("TOPLEFT", rel, point .. "LEFT", cAlign.x or padding.left, yOffset)
                else
                    -- CENTER
                    child:SetPoint("TOP", rel, point, cAlign.x or 0, yOffset)
                end
            else
                -- Comportamiento estándar: Ocupar todo el ancho
                child:SetPoint("TOP", rel, point, 0, yOffset)
                child:SetPoint("LEFT", container, "LEFT", padding.left, 0)
                child:SetPoint("RIGHT", container, "RIGHT", -padding.right, 0)
            end

            -- Cálculo de la altura
            totalHeight = totalHeight + child:GetHeight()
            if i < #children then
                totalHeight = totalHeight + spacing
            end
            lastChild = child
        end
    end

    container:SetHeight(totalHeight + padding.bottom)
end

---------------------------------------------------------------------
-- HSTACK: Apilado Horizontal
---------------------------------------------------------------------
function Utils:HStack(container, spacing, padding)
    local cfg = Utils:GetLayout(container.layoutConfig or {}, { 
        spacing = 8, 
        padding = { top = 10, bottom = 10, left = 10, right = 10 } 
    })
    
    spacing = spacing or cfg.spacing
    padding = self:NormalizePadding(padding or cfg.padding)

    local lastChild = nil
    local totalWidth = padding.left 

    local children = { container:GetChildren() }
    for i, child in ipairs(children) do
        if child:IsObjectType("Frame") and child:IsShown() then
            child:ClearAllPoints()
            
            -- Anclaje Horizontal
            if not lastChild then
                child:SetPoint("LEFT", container, "LEFT", padding.left, 0)
            else
                child:SetPoint("LEFT", lastChild, "RIGHT", spacing, 0)
            end

            -- Alineación Vertical
            local cAlign = child.customAlign
            if cAlign and cAlign.vAlign == "TOP" then
                child:SetPoint("TOP", container, "TOP", 0, -padding.top)
            elseif cAlign and cAlign.vAlign == "BOTTOM" then
                child:SetPoint("BOTTOM", container, "BOTTOM", 0, padding.bottom)
            end
            
            -- Cálculo del ancho
            totalWidth = totalWidth + child:GetWidth()
            if i < #children then
                totalWidth = totalWidth + spacing
            end
            lastChild = child
        end
    end

    container:SetWidth(totalWidth + padding.right)
end

---------------------------------------------------------------------
-- MISCELÁNEA
---------------------------------------------------------------------

function Utils:DrawBackground(frame, color)
    if not frame then return end
    frame.bg = frame.bg or frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(unpack(color or {1, 1, 1, 0.05}))
end

function Utils:Clear(frame)
    if not frame then return end
    
    for _, child in ipairs({ frame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
end