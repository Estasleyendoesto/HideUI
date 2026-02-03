local _, ns = ...
local Scroll = gUI:NewModule("Scroll")

---------------------------------------------------------------------
-- ESTÉTICA (INTERNO)
---------------------------------------------------------------------
local function ApplyScrollStyles(scrollFrame)
    local bar = scrollFrame.ScrollBar
    if not bar then return end

    -- Ocultar elementos sobrantes del template de Blizzard
    if bar.Track then bar.Track:Hide() end
    if bar.ScrollUpButton then bar.ScrollUpButton:Hide() end
    if bar.ScrollDownButton then bar.ScrollDownButton:Hide() end

    if bar.ThumbTexture then
        bar.ThumbTexture:SetAlpha(0.5)
    end
end

---------------------------------------------------------------------
-- LÓGICA DE MOVIMIENTO (INTERNO)
---------------------------------------------------------------------
local function HandleMouseWheel(self, delta)
    local maxScroll = self:GetVerticalScrollRange()
    if maxScroll <= 0 then return end

    local scrollStep = 30
    local current = self:GetVerticalScroll()
    local newPos = current - (delta * scrollStep)

    -- Clamp automático entre 0 y el máximo
    self:SetVerticalScroll(math.max(0, math.min(newPos, maxScroll)))
end

---------------------------------------------------------------------
-- CONSTRUCTOR
---------------------------------------------------------------------
function Scroll:Create(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    ApplyScrollStyles(scrollFrame)

    -- Lienzo interno (donde se anclarán los widgets)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1) 
    scrollFrame:SetScrollChild(content)

    -- Sincronización de ancho
    scrollFrame:SetScript("OnSizeChanged", function(self, width)
        content:SetWidth(width)
    end)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", HandleMouseWheel)

    return scrollFrame, content
end