local _, ns = ...
local Utils = gUI:NewModule("Utils")

---------------------------------------------------------------------
-- CONFIGURACIÓN Y LAYOUT
---------------------------------------------------------------------
function Utils:NormalizeBoxModel(value)
    if type(value) == "number" then
        return { top = value, bottom = value, left = value, right = value }
    end

    if not value or type(value) ~= "table" then
        return { top = 0, bottom = 0, left = 0, right = 0 }
    end

    local x = tonumber(value.x) or tonumber(value.horizontal) or 0
    local y = tonumber(value.y) or tonumber(value.vertical)   or 0

    return {
        top    = tonumber(value.top)    or y,
        bottom = tonumber(value.bottom) or y,
        left   = tonumber(value.left)   or x,
        right  = tonumber(value.right)  or x
    }
end

function Utils:NormalizePadding(p) return self:NormalizeBoxModel(p) end
function Utils:NormalizeMargin(m)  return self:NormalizeBoxModel(m) end

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
        margin     = self:NormalizeMargin(config.margin or config.m),
        spacing    = config.spacing or 0,
        opacity    = config.opacity or 1
    }
end

local function MergeBoxProperty(self, config, key, userValue)
    local userP = self:NormalizeBoxModel(userValue)
    config[key] = config[key] or self:NormalizeBoxModel(nil)

    for side, val in pairs(userP) do
        local isExplicit = false
        if type(userValue) == "number" then
            isExplicit = true
        elseif type(userValue) == "table" then
            if side == "left" or side == "right" then
                isExplicit = (userValue[side] ~= nil or userValue.x ~= nil)
            else
                isExplicit = (userValue[side] ~= nil or userValue.y ~= nil)
            end
        end

        if isExplicit then config[key][side] = val end
    end
end

function Utils:GetLayout(layout, defaults)
    local config = {}
    defaults = defaults or {}

    -- Cargar Defaults
    for k, v in pairs(defaults) do
        if k == "padding" or k == "p" then
            config.padding = self:NormalizePadding(v)
        elseif k == "margin" or k == "m" then
            config.margin = self:NormalizeMargin(v)
        else
            config[k] = v
        end
    end

    -- Mezclar Layout del Usuario
    if type(layout) == "table" then
        for k, v in pairs(layout) do
            if k == "padding" or k == "p" then
                MergeBoxProperty(self, config, "padding", v)
            elseif k == "margin" or k == "m" then
                MergeBoxProperty(self, config, "margin", v)
            else
                if v ~= nil then config[k] = v end
            end
        end
    end

    -- Asegurar consistencia final
    config.padding = self:NormalizePadding(config.padding)
    config.margin = self:NormalizeMargin(config.margin)
    
    return config
end

function Utils:RegisterLayout(frame, layout)
    frame.layoutConfig = self:GetLayout(layout)
end

---------------------------------------------------------------------
-- VSTACK: Apilado Vertical
---------------------------------------------------------------------
function Utils:VStack(container, spacing, padding)
    local cfg = self:GetLayout(container.layoutConfig or {}, { 
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
    local cfg = self:GetLayout(container.layoutConfig or {}, { 
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

function Utils:Dump(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        print(indent .. tostring(t))
        return
    end

    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. ": {")
            self:Dump(v, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. tostring(k) .. " = " .. tostring(v))
        end
    end
end
